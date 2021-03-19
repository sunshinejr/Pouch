enum OutputLanguageError: Error {
    case languageNotSupported(String)
}

public enum OutputLanguage: Codable, Equatable {
    case swift(SwiftConfig)
    
    enum CodingKeys: String, CodingKey {
        case language
        case config
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            let language = try container.decodeIfPresent(String.self, forKey: .language)
            
            switch language {
            case "swift":
                let config = try SwiftConfig(from: decoder)
                self = .swift(config)
            default:
                logger.log(.parser, "Language \"\(language ?? "")\" not supported, falling back to \"swift\"")
            }
        }
        
        let config = try SwiftConfig(from: decoder)
        self = .swift(config)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .swift(config):
            try container.encode("swift", forKey: .language)
            try config.encode(to: encoder)
        }
    }
}
