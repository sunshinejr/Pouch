public struct Output: Codable, Equatable {
    public let file: DecryptionFile
    public let representation: OutputRepresentation
    public let outputLanguage: OutputLanguage

    enum CodingKeys: String, CodingKey {
        case representation
    }

    public init(decryptionFile: DecryptionFile, representation: OutputRepresentation, outputLanguage: OutputLanguage) {
        self.file = decryptionFile
        self.representation = representation
        self.outputLanguage = outputLanguage
    }
    
    public init(from decoder: Decoder) throws {
        file = try DecryptionFile(from: decoder)
        outputLanguage = try OutputLanguage(from: decoder)
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            representation = (try container.decodeIfPresent(OutputRepresentation.self, forKey: .representation)) ?? Defaults.representation
        } else {
            representation = Defaults.representation
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try file.encode(to: encoder)
        try container.encode(representation, forKey: .representation)
        try outputLanguage.encode(to: encoder)
    }
}

public enum OutputRepresentation: String, Codable {
    case staticVariables
    case dictionary

    public func generateName(for variable: String) -> String {
        switch self {
        case .staticVariables:
            return variable.toCamelCase()
        case .dictionary:
            return variable.lowercased()
        }
    }
}
