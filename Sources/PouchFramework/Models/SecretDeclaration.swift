public struct SecretDeclaration {
    public let name: String
    public let encryption: Cipher
    
    public init(name: String, encryption: Cipher) {
        self.name = name
        self.encryption = encryption
    }
}

extension SecretDeclaration {
    func with(value: String) -> Secret {
        return .init(name: name, value: value, encryption: encryption)
    }
}
