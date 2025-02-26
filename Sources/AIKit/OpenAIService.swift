import AsyncAlgorithms
import Combine
import Foundation

public actor OpenAIService: APIRequestHandler {
    public static var debugMode = false
    public typealias Input = AIChatRequest
    public typealias Output = AIChatResponse

    private let configuration: AIKit.Configuration
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(configuration: AIKit.Configuration) {
        self.configuration = configuration
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
    }

    private func debug(_ message: String) {
        if Self.debugMode {
            print(message)
        }
    }

    public func sendRequest(_ input: AIChatRequest) async throws -> AIChatResponse {
        var request = try createRequest(for: input)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(input)

        let (data, response) = try await session.data(for: request)
        try validate(response: response, model: input.model)

        do {
            return try decoder.decode(AIChatResponse.self, from: data)
        } catch {
            throw AIError.invalidResponseFormat
        }
    }

    public func sendStreamRequest(_ input: AIChatRequest) async -> AsyncThrowingStream<
        AIChatResponse, Error
    > {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    var request = try createRequest(for: input)
                    request.httpMethod = "POST"

                    var modifiedInput = input
                    modifiedInput.stream = true
                    let encodedBody = try JSONEncoder().encode(modifiedInput)
                    request.httpBody = encodedBody

                    if let bodyString = String(data: encodedBody, encoding: .utf8) {
                        debug("Request body: \(bodyString)")
                    }

                    let (bytes, response) = try await session.bytes(for: request)

                    if let httpResponse = response as? HTTPURLResponse {
                        debug("Response status code: \(httpResponse.statusCode)")
                        debug("Response headers: \(httpResponse.allHeaderFields)")

                        if httpResponse.statusCode == 400 {
                            var errorData = Data()
                            for try await byte in bytes {
                                errorData.append(byte)
                            }
                            if let errorString = String(data: errorData, encoding: .utf8) {
                                debug("Error response: \(errorString)")
                            }
                            throw AIError.networkError(NSError(domain: "HTTP", code: 400))
                        }
                    }

                    try validate(response: response, model: input.model)

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let data = line.dropFirst(6)
                        guard !data.isEmpty, data != "[DONE]" else { continue }

                        if let responseData = data.data(using: .utf8),
                            let response = try? decoder.decode(
                                AIChatResponse.self, from: responseData)
                        {
                            if response.choices.first?.delta?.content != nil {
                                continuation.yield(response)
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func createRequest(for input: AIChatRequest) throws -> URLRequest {
        let baseURLString = configuration.provider.baseURL.absoluteString.trimmingCharacters(
            in: CharacterSet(charactersIn: "/"))
        let fullURL = URL(string: "\(baseURLString)/chat/completions")!

        debug("Request URL: \(fullURL.absoluteString)")

        var request = URLRequest(url: fullURL)
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        debug("Headers: \(request.allHTTPHeaderFields ?? [:])")

        return request
    }

    private func validate(response: URLResponse, model: String) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        debug("Response status code: \(httpResponse.statusCode)")
        debug("Response headers: \(httpResponse.allHeaderFields)")

        switch httpResponse.statusCode {
        case 200..<300: return
        case 401: throw AIError.invalidAPIKey
        case 404: throw AIError.modelNotAvailable(model)
        case 429: throw AIError.rateLimitExceeded(retryAfter: 60)
        default: throw AIError.networkError(NSError(domain: "HTTP", code: httpResponse.statusCode))
        }
    }
}
