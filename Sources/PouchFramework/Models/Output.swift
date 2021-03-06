public struct Output {
    public let decryptionFile: DecryptionFile
    public let outputLanguage: OutputLanguage
    
    public init(decryptionFile: DecryptionFile, outputLanguage: OutputLanguage) {
        self.decryptionFile = decryptionFile
        self.outputLanguage = outputLanguage
    }
}
