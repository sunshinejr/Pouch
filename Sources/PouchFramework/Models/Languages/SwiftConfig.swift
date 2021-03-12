public struct SwiftConfig: Codable {
    public let typeName: String
    
    enum CodingKeys: String, CodingKey {
        case typeName
    }
    
    public init(typeName: String) {
        self.typeName = typeName
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.typeName = (try? container.decode(String.self, forKey: .typeName)) ?? Defaults.Swift.typeName
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
    }
}
