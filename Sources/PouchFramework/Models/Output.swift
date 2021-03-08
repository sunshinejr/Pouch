public struct Output: Codable {
    public let file: DecryptionFile
    public let outputLanguage: OutputLanguage
    
    public init(decryptionFile: DecryptionFile, outputLanguage: OutputLanguage) {
        self.file = decryptionFile
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
