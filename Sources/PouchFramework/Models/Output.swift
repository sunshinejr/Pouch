public struct Output: Codable, Equatable {
    public let file: DecryptionFile
    public let outputLanguage: OutputLanguage

    public init(file: DecryptionFile, outputLanguage: OutputLanguage) {
        self.file = file
        self.outputLanguage = outputLanguage
    }
    
    public init(from decoder: Decoder) throws {
        file = try DecryptionFile(from: decoder)
        outputLanguage = try OutputLanguage(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try file.encode(to: encoder)
        try outputLanguage.encode(to: encoder)
    }
}

public enum OutputRepresentation: String, Codable {
    case variables
    case dictionary

    public func generateName(for variable: String) -> String {
        switch self {
        case .variables:
            return variable.toCamelCase()
        case .dictionary:
            return variable.lowercased()
        }
    }
}
