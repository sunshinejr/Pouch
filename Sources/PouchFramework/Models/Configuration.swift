import Foundation

public struct Configuration: Codable, Equatable {
    public let secrets: [SecretDeclaration]
    public let outputs: [Output]
    
    public init(secrets: [SecretDeclaration], outputs: [Output]) {
        self.secrets = secrets
        self.outputs = outputs
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.secrets = try container.decode([SecretDeclaration].self, forKey: .secrets)
        self.outputs = try container.decode([Output].self, forKey: .outputs)
    }
}
