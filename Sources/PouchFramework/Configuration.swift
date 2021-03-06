import Foundation

public struct Configuration {
    public let input: Input
    public let outputs: [Output]
    public let encryption: Cipher
    
    public init(input: Input, outputs: [Output], encryption: Cipher) {
        self.input = input
        self.outputs = outputs
        self.encryption = encryption
    }
}
