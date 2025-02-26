import Combine
import Foundation

@preconcurrency public protocol APIRequestHandler {
    associatedtype Input: Encodable & Sendable
    associatedtype Output: Decodable & Sendable
    
    func sendRequest(_ input: Input) async throws -> Output
    func sendStreamRequest(_ input: Input) async -> AsyncThrowingStream<Output, Error>
}

public struct AIChatMessage: Codable, Identifiable, Sendable {
    public var id: UUID
    public let role: Role
    public let content: String
    
    public init(role: Role, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
    }
    
    public enum Role: String, Codable, Sendable {
        case system
        case user
        case assistant
    }
}

public struct AIChatResponse: Decodable, Sendable {
    public let id: String?  // Optional for streaming
    public let object: String?  // Optional for streaming
    public let created: Int?  // Optional for streaming
    public let choices: [Choice]
    public let usage: Usage?
    
    public struct Choice: Decodable, Sendable {
        public let index: Int?  // Optional for streaming
        public let message: AIChatMessage?
        public let delta: Delta?
        
        public struct Delta: Decodable, Sendable {
            private enum CodingKeys: String, CodingKey {
                case role
                case content
            }
            
            public let role: AIChatMessage.Role?
            public let content: String?
            
            public init(from decoder: Decoder) throws {
                if let container = try? decoder.container(keyedBy: CodingKeys.self) {
                    role = try container.decodeIfPresent(AIChatMessage.Role.self, forKey: .role)
                    content = try container.decodeIfPresent(String.self, forKey: .content)
                } else {
                    // If it's just a string, treat it as content
                    let container = try decoder.singleValueContainer()
                    content = try? container.decode(String.self)
                    role = nil
                }
            }
        }
    }
    
    public struct Usage: Decodable, Sendable {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int
    }
}
