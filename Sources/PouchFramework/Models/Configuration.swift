import Foundation

public struct EnvironmentConfiguration: Codable, Equatable {
    public let input: Input?
    public let secrets: [SecretDeclaration]?
    public let outputs: [Output]?

    public init(input: Input? = nil, secrets: [SecretDeclaration]? = nil, outputs: [Output]? = nil) {
        self.input = input
        self.secrets = secrets
        self.outputs = outputs
    }
}

public struct Configuration: Codable, Equatable {
    public let input: Input
    public let secrets: [SecretDeclaration]
    public let outputs: [Output]
    public let environments: [String: EnvironmentConfiguration]?

    public var configurations: [String: Configuration] {
        if let environments, !environments.keys.isEmpty {
            return environments.reduce(into: [String: Configuration]()) { $0[$1.key] = configuration(for: $1.key) }
        } else {
            return ["main": self]
        }
    }

    public init(
        input: Input,
        secrets: [SecretDeclaration],
        outputs: [Output],
        environments: [String: EnvironmentConfiguration]? = nil
    ) {
        self.input = input
        self.secrets = secrets
        self.outputs = outputs
        self.environments = environments
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        input = try (container.decodeIfPresent(Input.self, forKey: .input)) ?? Defaults.input
        secrets = try container.decode([SecretDeclaration].self, forKey: .secrets)
        outputs = try (container.decodeIfPresent([Output].self, forKey: .outputs)) ?? []
        environments = try container.decodeIfPresent([String: EnvironmentConfiguration].self, forKey: .environments)
    }

    public func configuration(for environment: String?) -> Configuration {
        guard let environment = environment,
              let environments = environments,
              let envConfig = environments[environment] else
        {
            return self
        }

        return Configuration(
            input: envConfig.input ?? input,
            secrets: envConfig.secrets ?? secrets,
            outputs: envConfig.outputs ?? outputs
        )
    }
}
