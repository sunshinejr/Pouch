import CryptoKit
import FirebaseCore
import FirebaseRemoteConfig
import Foundation

public final class FirebaseRemoteConfigFetcher {
    public enum Error: Swift.Error {
        case configFileNotFound(String)
        case keysNotFound([String])
        case invalidProjectId
        case networkError(Swift.Error)
        case invalidResponse(String)
    }

    private let configPath: String

    public init(configPath: String) throws {
        self.configPath = configPath
        logger.log(.variableFetcher, "[Firebase] RemoteConfig initialized, fetching secrets...")
    }

    public func fetch(declarations: [KeyDeclaration], keyMapping: [String: String]) async throws -> [Key] {
        FirebaseConfiguration.shared.setLoggerLevel(.max)
        guard let options = FirebaseOptions(contentsOfFile: configPath) else {
            throw Error.configFileNotFound(configPath)
        }
        options.useMemoryOnlyInstallations = true
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0

        let appName = "pouch_\(options.googleAppID.hashValue)"
        FirebaseApp.configure(name: appName, options: options)
        // The wait above is needed with multiple configurations/apps
        // I started debugging why - the issue seems to be that options are not properly propagated to the RemoteConfig internals
        // i.e. if we print options.googleAppID here and app.options.googleAppID, they are the same, but somehow copied options
        // inside RemoteConfig are different
        try? await Task.sleep(for: .milliseconds(2000))
        let app = FirebaseApp.app(name: appName)!
        let remoteConfig = RemoteConfig.remoteConfig(app: app)
        remoteConfig.configSettings = settings
        try await remoteConfig.fetch()
        logger.log(.variableFetcher, "[Firebase] Fetched data, now activating any existing A/B tests...")
        try await remoteConfig.activate()
        logger.log(.variableFetcher, "[Firebase] Activated any existing A/B tests for RemoteConfig")

        let fetchedKeys = declarations.compactMap { declaration -> Key? in
            let mappedKey = keyMapping[declaration.name] ?? declaration.name
            let value = remoteConfig.configValue(forKey: mappedKey).stringValue
            guard !value.isEmpty else {
                logger.log(.variableFetcher, "[Firebase] Missing value for key: \(mappedKey, color: .red)")
                return nil
            }

            return Key(
                name: declaration.name,
                value: value,
                generatedName: declaration.generatedName
            )
        }
        await app.delete()
        try? await Task.sleep(for: .milliseconds(100))

        if fetchedKeys.count != declarations.count {
            let keysMissing = declarations.filter { key in
                fetchedKeys.first { $0.name == key.name } == nil
            }
            throw Error.keysNotFound(keysMissing.map { $0.name })
        }

        return fetchedKeys
    }
}
