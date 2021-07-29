public enum Input: String, Codable, Equatable {
    case environmentVariable
    case input
    
    enum CodingKeys: String, CodingKey {
        case environmentVariable = "env"
        case input
    }
}
