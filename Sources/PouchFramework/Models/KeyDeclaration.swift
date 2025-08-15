public struct KeyDeclaration: Codable, Equatable {
    public let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    public init(name: String) {
        self.name = name
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), let name = try? container.decode(String.self) {
            self.init(name: name)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let name = try container.decode(String.self, forKey: .name)
            self.init(name: name)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

extension KeyDeclaration {
    func with(value: String) -> Key {
        return .init(name: name, value: value)
    }
}
