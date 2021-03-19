public struct DecryptionFile: Codable, Equatable {
    public let filePath: String
    
    enum CodingKeys: String, CodingKey {
        case filePath
    }
    
    public init(filePath: String) {
        self.filePath = filePath
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), let filePath = try? container.decode(String.self) {
            self.init(filePath: filePath)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let filePath = try container.decode(String.self, forKey: .filePath)
            self.init(filePath: filePath)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(filePath)
    }
}
