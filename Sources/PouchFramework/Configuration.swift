import Foundation

/// Type that describes information about the file that reads decrypted secrets
/// E.g. given DecryptionFileConfig(fileName: "Constants.swift", typeName: "Constants",)
/// And secrets: `["api_key", "api_secret"]`
/// You will be able to access them using `Constants.apiKey`, `Constants.apiSecret`
public struct DecryptionFileConfig {
    public let fileName: String
    public let typeName: String
}

public enum Output {
    case swift(DecryptionFileConfig)
}

public enum Cipher {
    case xor
}

public enum Encryption {
    case cipher(Cipher)
}

public struct Configuration {
    public let input: Input
    public let output: Output
    public let encryption: Cipher
}
