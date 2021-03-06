import Foundation

public struct Configuration {
    public let input: Input
    public let secrets: [SecretDeclaration]
    public let outputs: [Output]
    
    public init(input: Input, secrets: [SecretDeclaration], outputs: [Output]) {
        self.input = input
        self.secrets = secrets
        self.outputs = outputs
    }
}
