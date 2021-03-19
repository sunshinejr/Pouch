public enum Input: String, Codable, Equatable {
    case environmentVariable
    
    enum CodingKeys: String, CodingKey {
        case environmentVariable = "env"
    }
}
