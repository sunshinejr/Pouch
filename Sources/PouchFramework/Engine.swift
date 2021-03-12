import Foundation

public struct Engine {
    public init() {}
    
    public func createFiles(configuration: Configuration) {
        logger.log(.variableFetcher, "Resolving input variables...")
        resolve(declarations: configuration.secrets, input: configuration.input) { result in
            switch result {
            case let .success(secrets):
                for output in configuration.outputs {
                    do {
                        logger.log(.variableFetcher, "Input variables resolved successfully!")
                        logger.log(.fileWriter, "Generating file output at \(output.file.filePath, color: .green)...")
                        let contents = try generateFileContents(secrets: secrets, output: output, logger: logger)
                        try write(fileContents: contents, to: output.file)
                        logger.log(.fileWriter, "Generated file output at \(output.file.filePath, color: .green) successfully!")
                    } catch {
                        logger.log(.fileWriter, "Couldn't generate file output at \(output.file.filePath, color: .green): \(error, color: .red)")
                    }
                }
            case let .failure(error):
                logger.log(.variableFetcher, "Couldn't retrieve input variables: \(error, color: .red)")
            }
        }
    }
    
    private func resolve(declarations: [SecretDeclaration], input: Input, completion: (Result<[Secret], Error>) -> Void) {
        switch input {
        case .environmentVariable:
            EnvironmentVariableFetcher().fetch(secrets: declarations, completion: completion)
        }
    }
    
    private func generateFileContents(secrets: [Secret], output: Output, logger: Logging) throws -> String {
        switch output.outputLanguage {
        case let .swift(swiftConfig):
            return SwiftGenerator().generateFileContents(secrets: secrets, config: swiftConfig)
        }
    }
    
    private func write(fileContents contents: String, to file: DecryptionFile) throws {
        let url = URL(fileURLWithPath: file.filePath)
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }
}
