public enum Input: Codable, Equatable {
    public enum Error: Swift.Error {
        case configPathRequired
        case invalidInputType
    }

    public enum Constants {
        public static let firebaseRemoteConfig = "firebase"
        public static let environmentVariable = "env"
    }
    
    public enum CodingKeys: String, CodingKey {
        case type
        case configPath
    }    

    case environmentVariable
    case firebaseRemoteConfig(String)

    public var typeDescription: String {
        switch self {
        case .environmentVariable: Constants.environmentVariable
        case .firebaseRemoteConfig: Constants.firebaseRemoteConfig
        }
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            let type = try container.decode(String.self, forKey: .type)
            switch type {
                case Constants.environmentVariable:
                    self = .environmentVariable
                case Constants.firebaseRemoteConfig:
                    guard let configPath = try container.decodeIfPresent(String.self, forKey: .configPath) else {
                        throw Error.configPathRequired
                    }
                    self = .firebaseRemoteConfig(configPath)
                default:
                    throw Error.invalidInputType
            }
        } else {
            let container = try decoder.singleValueContainer()
            let type = try container.decode(String.self)
            switch type {
                case Constants.environmentVariable:
                    self = .environmentVariable
                default:
                    throw Error.invalidInputType
            }
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeDescription, forKey: .type)

        switch self {
        case let .firebaseRemoteConfig(configPath):
            try container.encode(configPath, forKey: .configPath)
        case .environmentVariable:
            break
        }
    }
}
