import Foundation
import CryptoKit
import FirebaseCore
import FirebaseRemoteConfig

public final class FirebaseRemoteConfigFetcher: VariableFetching {
    public enum Error: Swift.Error {
        case configFileNotFound(String)
        case secretsNotFound([String])
        case invalidProjectId
        case networkError(Swift.Error)
        case invalidResponse(String)
    }

    private let configPath: String

    public init(configPath: String) throws {
        self.configPath = configPath
    }
    
    public func fetch(secrets: [SecretDeclaration]) async throws -> [Secret] {
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
        // i.e. if we print options.googleAppID here and app.options.googleAppID, they are the same, but somehow copied options inside RemoteConfig are different
        try? await Task.sleep(for: .milliseconds(1000))
        let app = FirebaseApp.app(name: appName)!
        let remoteConfig = RemoteConfig.remoteConfig(app: app)
        remoteConfig.configSettings = settings
        try await remoteConfig.fetch()
        logger.log(.variableFetcher, "[Firebase] Fetched data, now activating any existing A/B tests...")
        try await remoteConfig.activate()
        logger.log(.variableFetcher, "[Firebase] Activated any existing A/B tests for RemoteConfig")

        let fetchedSecrets = secrets.compactMap { declaration -> Secret? in
            let value = remoteConfig.configValue(forKey: declaration.name).stringValue
            guard !value.isEmpty else {
                logger.log(.variableFetcher, "[Firebase] Missing value for key: \(declaration.name, color: .red)")
                return nil
            }

            return Secret(
                name: declaration.name,
                generatedName: declaration.generatedName,
                value: value,
                encryption: .xor
            )
        }
        await app.delete()
        try? await Task.sleep(for: .milliseconds(100))

        if fetchedSecrets.count != secrets.count {
            let secretsMissing = secrets.filter { secret in
                fetchedSecrets.first { $0.name == secret.name } == nil
            }
            throw Error.secretsNotFound(secretsMissing.map { $0.name })
        }

        return fetchedSecrets
    }
}
