public enum Input: Codable, Equatable {
    public enum Error: Swift.Error {
        case configPathRequired
        case vaultRequired
        case sectionRequired
        case invalidInputType
    }

    public enum Constants {
        public static let firebaseRemoteConfig = "firebase"
        public static let environmentVariable = "env"
        public static let onePassword = "1password"
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case configPath
        case vault
        case account
        case section
        case keyMapping
    }

    case onePassword(_ vault: String, _ account: String?, _ section: String, _ keyMapping: [String: String])
    case environmentVariable(_ keyMapping: [String: String])
    case firebaseRemoteConfig(String, _ keyMapping: [String: String])

    public var typeDescription: String {
        switch self {
        case .onePassword: Constants.onePassword
        case .environmentVariable: Constants.environmentVariable
        case .firebaseRemoteConfig: Constants.firebaseRemoteConfig
        }
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            let type = try container.decode(String.self, forKey: .type)
            let keyMapping = try container.decodeIfPresent([String: String].self, forKey: .keyMapping)
            switch type {
            case Constants.environmentVariable:
                self = .environmentVariable(keyMapping ?? [:])
            case Constants.firebaseRemoteConfig:
                guard let configPath = try container.decodeIfPresent(String.self, forKey: .configPath) else {
                    throw Error.configPathRequired
                }
                self = .firebaseRemoteConfig(configPath, keyMapping ?? [:])
            case Constants.onePassword:
                guard let vault = try container.decodeIfPresent(String.self, forKey: .vault) else {
                    throw Error.vaultRequired
                }
                let account = try container.decodeIfPresent(String.self, forKey: .account)
                guard let section = try container.decodeIfPresent(String.self, forKey: .section) else {
                    throw Error.sectionRequired
                }
                self = .onePassword(vault, account, section, keyMapping ?? [:])
            default:
                throw Error.invalidInputType
            }
        } else {
            let container = try decoder.singleValueContainer()
            let type = try container.decode(String.self)
            switch type {
            case Constants.environmentVariable:
                self = .environmentVariable([:])
            default:
                throw Error.invalidInputType
            }
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeDescription, forKey: .type)

        switch self {
        case let .firebaseRemoteConfig(configPath, keyMapping):
            try container.encode(configPath, forKey: .configPath)
            try container.encode(keyMapping, forKey: .keyMapping)
        case let .onePassword(vault, account, section, keyMapping):
            try container.encode(vault, forKey: .vault)
            if let account = account {
                try container.encode(account, forKey: .account)
            }
            try container.encode(section, forKey: .section)
            try container.encode(keyMapping, forKey: .keyMapping)
        case let .environmentVariable(keyMapping):
            try container.encode(keyMapping, forKey: .keyMapping)
        }
    }
}
