public struct DecryptionFile: Codable {
    public let filePath: String
    
    public init(filePath: String) {
        self.filePath = filePath
    }
}
