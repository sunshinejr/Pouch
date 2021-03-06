import Foundation

public struct Configuration {
    public let input: Input
    public let secrets: [Secret]
    public let outputs: [Output]
    
    public init(input: Input, secrets: [Secret], outputs: [Output]) {
        self.input = input
        self.secrets = secrets
        self.outputs = outputs
    }
}
