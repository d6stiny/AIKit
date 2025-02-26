import Foundation

public enum AIError: Error, LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case rateLimitExceeded(retryAfter: TimeInterval)
    case contextWindowExceeded(current: Int, max: Int)
    case invalidResponseFormat
    case modelNotAvailable(String)
    case serializationError(Error)
    case invalidURL
    case invalidResponse
    
    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey: "Invalid API key"
        case .networkError(let error): "Network error: \(error.localizedDescription)"
        case .rateLimitExceeded(let retryAfter): 
            "Rate limit exceeded. Retry after \(Int(retryAfter)) seconds"
        case .contextWindowExceeded(let current, let max):
            "Context window exceeded (\(current)/\(max) tokens)"
        case .invalidResponseFormat: "Invalid response format"
        case .modelNotAvailable(let model): "Model \(model) not available"
        case .serializationError(let error): "Serialization error: \(error.localizedDescription)"
        case .invalidURL: "Invalid API URL"
        case .invalidResponse: "Invalid server response"
        }
    }
}
