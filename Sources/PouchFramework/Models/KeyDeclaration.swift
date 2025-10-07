public struct KeyDeclaration: Codable, Equatable {
    public let name: String
    public let generatedName: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case generatedName
    }
    
    public init(name: String, generatedName: String? = nil) {
        self.name = name
        self.generatedName = generatedName
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), let name = try? container.decode(String.self) {
            self.init(name: name)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let name = try container.decode(String.self, forKey: .name)
            let generatedName = try? container.decodeIfPresent(String.self, forKey: .generatedName)
            self.init(name: name, generatedName: generatedName)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if generatedName == nil {
            var container = encoder.singleValueContainer()
            try container.encode(name)
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(generatedName, forKey: .generatedName)
        }
    }
}

extension KeyDeclaration {
    func with(value: String) -> Key {
        return .init(name: name, value: value, generatedName: generatedName)
    }
}
