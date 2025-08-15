import Foundation

public struct EnvironmentConfiguration: Codable, Equatable {
    public let input: Input?
    public let keys: [KeyDeclaration]?
    public let outputs: [Output]?

    public init(input: Input? = nil, keys: [KeyDeclaration]? = nil, outputs: [Output]? = nil) {
        self.input = input
        self.keys = keys
        self.outputs = outputs
    }
}

public struct Configuration: Codable, Equatable {
    public let keys: [KeyDeclaration]
    public let input: Input?
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
        keys: [KeyDeclaration],
        input: Input?,
        outputs: [Output],
        environments: [String: EnvironmentConfiguration]? = nil
    ) {
        self.input = input
        self.keys = keys
        self.outputs = outputs
        self.environments = environments
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        keys = try container.decode([KeyDeclaration].self, forKey: .keys)
        input = try container.decodeIfPresent(Input.self, forKey: .input)
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
            keys: envConfig.keys ?? keys,
            input: envConfig.input ?? input,
            outputs: envConfig.outputs ?? outputs
        )
    }
}
