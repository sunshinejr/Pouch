public struct SecretDeclaration: Codable {
    public let name: String
    public let generatedName: String?
    public let encryption: Cipher
    
    enum CodingKeys: String, CodingKey {
        case name
        case generatedName
        case encryption
    }
    
    public init(name: String, generatedName: String? = nil, encryption: Cipher) {
        self.name = name
        self.generatedName = generatedName
        self.encryption = encryption
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), let name = try? container.decode(String.self) {
            self.init(name: name, encryption: Defaults.encryption)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let name = try container.decode(String.self, forKey: .name)
            let generatedName = try container.decodeIfPresent(String.self, forKey: .generatedName)
            let encryption = (try container.decodeIfPresent(Cipher.self, forKey: .encryption)) ?? Defaults.encryption
            self.init(name: name, generatedName: generatedName, encryption: encryption)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if encryption == Defaults.encryption {
            var container = encoder.singleValueContainer()
            try container.encode(name)
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encodeIfPresent(generatedName, forKey: .generatedName)
            try container.encode(encryption, forKey: .encryption)
        }
    }
}

extension SecretDeclaration {
    func with(value: String) -> Secret {
        return .init(name: name, generatedName: generatedName, value: value, encryption: encryption)
    }
}
