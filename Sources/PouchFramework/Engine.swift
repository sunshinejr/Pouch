import Foundation

public final class Engine {
    private var onePasswordFetcher: OnePasswordFetcher?

    public init() {}

    public func createFiles(configuration: Configuration, printSecrets: Bool) async {
        logger.log(.variableFetcher, "Resolving input variables...")
        for (env, configuration) in configuration.configurations {
            guard let input = configuration.input else {
                logger.log(.variableFetcher, "No input provided for \(env, color: .red) environment, skipping...")
                continue
            }

            logger.log(.variableFetcher, "Using \(input.typeDescription, color: .blue) as input for \(env, color: .cyan) environment...")
            do {
                let keys = try await resolve(declarations: configuration.keys, input: input)
                if printSecrets {
                    logger.log(.variableFetcher, "Resolved secrets:\n\(keys.map { "\($0.name): \($0.value)" }.joined(separator: "\n"), color: .blue)")
                }
                logger.log(.variableFetcher, "Input variables resolved successfully!")
                for output in configuration.outputs {
                    do {
                        logger.log(.fileWriter, "Generating file output at \(output.file.filePath, color: .green)...")
                        let contents = try generateFileContents(keys: keys, output: output, logger: logger)
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

    public func resolve(declarations: [KeyDeclaration], input: Input) async throws -> [Key] {
        switch input {
        case let .environmentVariable(keyMapping):
            return try await EnvironmentVariableFetcher().fetch(declarations: declarations, keyMapping: keyMapping)
        case let .firebaseRemoteConfig(configPath, keyMapping):
            let fetcher = try FirebaseRemoteConfigFetcher(configPath: configPath)
            return try await fetcher.fetch(declarations: declarations, keyMapping: keyMapping)
        }
    }

    public func generateFileContents(keys: [Key], output: Output, logger _: Logging) throws -> String {
        switch output.outputLanguage {
        case let .swift(swiftConfig):
            return SwiftGenerator().generateFileContents(keys: keys, config: swiftConfig)
        }
    }

    private func write(fileContents contents: String, to file: DecryptionFile) throws {
        let url = URL(fileURLWithPath: file.filePath)
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }
}
