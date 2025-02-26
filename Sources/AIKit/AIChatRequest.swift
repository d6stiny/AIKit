public struct AIChatRequest: Encodable, Sendable {
    public let model: String
    public let messages: [AIChatMessage]
    public let temperature: Double
    
    private enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
        case stream
    }
    
    public let maxTokens: Int
    public var stream: Bool
    
    public init(
        model: String,
        messages: [AIChatMessage],
        temperature: Double = 0.7,
        maxTokens: Int = 2000,
        stream: Bool = false
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.stream = stream
    }
}
