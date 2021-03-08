public struct Secret {
    public let name: String
    public let generatedName: String?
    public let value: String
    public let encryption: Cipher
    
    public init(name: String, generatedName: String?, value: String, encryption: Cipher) {
        self.name = name
        self.generatedName = generatedName
        self.value = value
        self.encryption = encryption
    }
}
