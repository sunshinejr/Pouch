public struct Secret {
    public let name: String
    public let encryption: Cipher
    
    public init(name: String, encryption: Cipher) {
        self.name = name
        self.encryption = encryption
    }
}
