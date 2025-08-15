public struct SwiftConfig: Codable, Equatable {
    public enum AccessLevel: String, Codable {
        case `public`
        case `internal`
        case `private`
        case `fileprivate`
    }

    public let accessLevel: AccessLevel
    public let typeName: String
    public let isStatic: Bool
    public let encryption: Cipher
    public let representation: OutputRepresentation
    public let implementations: [String]
    public let keyMapping: [String: String]

    enum CodingKeys: String, CodingKey {
        case accessLevel
        case typeName
        case isStatic
        case encryption
        case representation
        case implementations
        case keyMapping
    }

    public init(accessLevel: AccessLevel, typeName: String, isStatic: Bool, implementations: [String], encryption: Cipher, representation: OutputRepresentation, keyMapping: [String: String] = [:]) {
        self.accessLevel = accessLevel
        self.typeName = typeName
        self.isStatic = isStatic
        self.implementations = implementations
        self.encryption = encryption
        self.representation = representation
        self.keyMapping = keyMapping
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            accessLevel = (try? container.decodeIfPresent(AccessLevel.self, forKey: .accessLevel)) ?? Defaults.Swift.accessLevel
            typeName = (try? container.decode(String.self, forKey: .typeName)) ?? Defaults.Swift.typeName
            isStatic = (try? container.decode(Bool.self, forKey: .isStatic)) ?? Defaults.Swift.isStatic
            implementations = (try? container.decodeIfPresent([String].self, forKey: .implementations)) ?? []
            encryption = (try? container.decodeIfPresent(Cipher.self, forKey: .encryption)) ?? Defaults.Swift.encryption
            representation = try (container.decodeIfPresent(OutputRepresentation.self, forKey: .representation)) ?? Defaults.Swift
                .representation
            keyMapping = (try? container.decodeIfPresent([String: String].self, forKey: .keyMapping)) ?? [:]
        } else {
            accessLevel = Defaults.Swift.accessLevel
            typeName = Defaults.Swift.typeName
            isStatic = Defaults.Swift.isStatic
            implementations = Defaults.Swift.implementations
            encryption = Defaults.Swift.encryption
            representation = Defaults.Swift.representation
            keyMapping = [:]
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessLevel, forKey: .accessLevel)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(implementations, forKey: .implementations)
        try container.encode(encryption, forKey: .encryption)
        try container.encode(representation, forKey: .representation)
        try container.encode(keyMapping, forKey: .keyMapping)
    }
}
