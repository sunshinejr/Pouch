public enum Input: String, Codable {
    case environmentVariable
    
    enum CodingKeys: String, CodingKey {
        case environmentVariable = "env"
    }
}
