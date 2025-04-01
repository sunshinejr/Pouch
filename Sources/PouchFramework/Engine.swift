import Foundation

public struct Engine {
    public init() {}

    public func createFiles(configuration: Configuration, printSecrets: Bool) async {
        logger.log(.variableFetcher, "Resolving input variables...")
        for (env, configuration) in configuration.configurations {
            logger.log(.variableFetcher, "Using \(configuration.input.typeDescription, color: .blue) as input for \(env, color: .cyan) environment...")
            do {
                let secrets = try await resolve(declarations: configuration.secrets, input: configuration.input)
                if printSecrets {
                    logger.log(.variableFetcher, "Resolved secrets:\n\(secrets.map { "\($0.name): \($0.value)" }.joined(separator: "\n"), color: .blue)")
                }
                logger.log(.variableFetcher, "Input variables resolved successfully!")
                for output in configuration.outputs {
                    do {
                        logger.log(.fileWriter, "Generating file output at \(output.file.filePath, color: .green)...")
                        let contents = try generateFileContents(secrets: secrets, output: output, logger: logger)
                        try write(fileContents: contents, to: output.file)
                        logger.log(.fileWriter, "Generated file output at \(output.file.filePath, color: .green) successfully!")
                    } catch {
                        logger.log(.fileWriter, "Couldn't generate file output at \(output.file.filePath, color: .green): \(error, color: .red)")
                    }
                }
            } catch {
                logger.log(.variableFetcher, "Couldn't retrieve input variables: \(error, color: .red)")
            }
        }
    }

    public func resolve(declarations: [SecretDeclaration], input: Input) async throws -> [Secret] {
        switch input {
        case .environmentVariable:
            return try await EnvironmentVariableFetcher().fetch(secrets: declarations)
        case let .firebaseRemoteConfig(configPath):
            let fetcher = try FirebaseRemoteConfigFetcher(configPath: configPath)
            logger.log(.variableFetcher, "Config initialized, fetching secrets...")
            return try await fetcher.fetch(secrets: declarations)
        }
    }

    public func generateFileContents(secrets: [Secret], output: Output, logger _: Logging) throws -> String {
        switch output.outputLanguage {
        case let .swift(swiftConfig):
            return SwiftGenerator().generateFileContents(secrets: secrets, representation: output.representation, config: swiftConfig)
        }
    }

    private func write(fileContents contents: String, to file: DecryptionFile) throws {
        let url = URL(fileURLWithPath: file.filePath)
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }
}
