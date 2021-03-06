import Foundation

public struct Engine {
    public init() {}
    
    public func createFiles(configuration: Configuration) {
        resolve(declarations: configuration.secrets, input: configuration.input) { result in
            switch result {
            case let .success(secrets):
                for output in configuration.outputs {
                    do {
                        let contents = try generateFileContents(secrets: secrets, output: output)
                        try write(fileContents: contents, to: output.decryptionFile)
                    } catch {
                        print("Couldn't generate file to \(output.decryptionFile.fileName).")
                        print("Error: \(error)")
                    }
                }
            case let .failure(error):
                print("Couldn't retrieve input variables.")
                print("Error: \(error)")
            }
        }
    }
    
    private func resolve(declarations: [SecretDeclaration], input: Input, completion: (Result<[Secret], Error>) -> Void) {
        switch input {
        case .environmentVariable:
            EnvironmentVariableFetcher().fetch(secrets: declarations, completion: completion)
        }
    }
    
    private func generateFileContents(secrets: [Secret], output: Output) throws -> String {
        switch output.outputLanguage {
        case let .swift(swiftConfig):
            return SwiftGenerator().generateFileContents(secrets: secrets, config: swiftConfig)
        }
    }
    
    private func write(fileContents contents: String, to file: DecryptionFile) throws {
        let url = URL(fileURLWithPath: file.fileName)
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }
}
