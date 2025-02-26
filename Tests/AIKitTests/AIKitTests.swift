import Foundation
import Testing

@testable import AIKit

@Suite struct AIKitTests {
    static let config = AIKit.Configuration(
        provider: .custom(URL(string: "http://127.0.0.1:1234/v1")!),
        apiKey: "lm-studio"
    )

    @Test func streamProcessing() async throws {
        let service = OpenAIService(configuration: Self.config)
        let request = AIChatRequest(
            model: "mistral-7b-instruct-v0.3",
            messages: [AIChatMessage(role: .user, content: "Hello")],
            temperature: 0.7,
            maxTokens: 100,
            stream: true
        )

        var responses = 0
        for try await _ in await service.sendStreamRequest(request) {
            responses += 1
        }

        #expect(responses > 0)
    }
}
