import AIKit
import Foundation

let config = AIKit.Configuration(
    provider: .custom(URL(string: "http://127.0.0.1:1234/v1")!),
    apiKey: "lm-studio"
)

let service = OpenAIService(configuration: config)
let context = ConversationContext(maxTokenCount: 4000)

while true {
    print("\nYou: ", terminator: "")

    guard let input = readLine(), input.lowercased() != "exit" else {
        break
    }

    let message = AIChatMessage(role: .user, content: input)
    context.append(message)

    let request = AIChatRequest(
        model: "mistral-7b-instruct-v0.3",
        messages: context.getAllMessages(),
        temperature: 0.7,
        maxTokens: 2000,
        stream: true
    )

    print("\nAI: ", terminator: "")
    var responseMessage = ""

    for try await response in await service.sendStreamRequest(request) {
        if let content = response.choices.first?.delta?.content {
            responseMessage += content
            print(content, terminator: "")
            fflush(stdout)
        }
    }

    context.append(AIChatMessage(role: .assistant, content: responseMessage))
}
