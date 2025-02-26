public class ConversationContext {
    private var messages: [AIChatMessage] = []
    private let maxTokenCount: Int

    public var currentTokenCount: Int {
        // Simple approximation: 1 character = 1 token
        messages.reduce(0) { count, message in
            count + message.content.count
        }
    }

    public init(maxTokenCount: Int) {
        self.maxTokenCount = maxTokenCount
    }

    public func append(_ message: AIChatMessage) {
        // If adding this message would exceed the token limit,
        // remove older messages until it fits
        var newCount = message.content.count
        var updatedMessages = [message]

        // Add newer messages first, working backwards
        for existingMessage in messages.reversed() {
            let messageCount = existingMessage.content.count
            if newCount + messageCount <= maxTokenCount {
                newCount += messageCount
                updatedMessages.insert(existingMessage, at: 0)
            } else {
                break
            }
        }

        messages = updatedMessages
    }

    public func getAllMessages() -> [AIChatMessage] {
        messages
    }
}
