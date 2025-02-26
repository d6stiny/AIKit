import Foundation

final public class AIKit {
    public struct Configuration: Sendable {
        public enum Provider: Sendable {
            case openai
            case custom(URL)

            var baseURL: URL {
                switch self {
                case .openai:
                    return URL(string: "https://api.openai.com/v1")!
                case .custom(let url):
                    return url
                }
            }
        }

        public let provider: Provider
        public let apiKey: String
        public let defaultTemperature: Double
        public let maxTokens: Int

        public init(
            provider: Provider = .openAI,
            baseURL: URL? = nil,
            apiKey: String,
            defaultTemperature: Double = 0.7,
            maxTokens: Int = 2000
        ) {
            self.provider = baseURL.map { .custom($0) } ?? provider
            self.apiKey = apiKey
            self.defaultTemperature = defaultTemperature
            self.maxTokens = maxTokens
        }
    }

    private let service: OpenAIService

    public init(configuration: Configuration) {
        self.service = OpenAIService(configuration: configuration)
    }

    public func chat(_ request: AIChatRequest) async throws -> AIChatResponse {
        try await service.sendRequest(request)
    }

    public func streamChat(_ request: AIChatRequest) async -> AsyncThrowingStream<
        AIChatResponse, Error
    > {
        await service.sendStreamRequest(request)
    }
}
