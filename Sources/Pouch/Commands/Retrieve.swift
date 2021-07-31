import ArgumentParser
import Foundation
import PouchFramework
import Yams

public struct Retrieve: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Retrieve secrets & generate files at given paths with given configuration.")
    
    @Option(help: "The config file used to generate the files.")
    var config: String = "./.pouch.yml"

    enum FetchInput: EnumerableFlag {
        case env
        case envOrStdin
    }

    @Flag(help: "Fetcher choice that overrides to env automatically when CI=true.")
    var input: FetchInput = .envOrStdin

    public init() {}

    public func run() throws {
        do {
            // Since we cannot extend YAMLDecoder to attach a logger, work around that by setting a global logger property.
            PouchFramework.logger = logger
            logger.log(.parser, "Reading \(config, color: .green)...")
            let config = try String(contentsOf: URL(fileURLWithPath: self.config))
            let mappedConfig: Configuration = try YAMLDecoder().decode(from: config)
            logger.log(.parser, "\(self.config, color: .green) parsed successfully!")

            let fetchInput: Input
            // Pouch should never ask for standard input when command is ran on CI
            if ProcessInfo.processInfo.environment[Defaults.EnvironmentCI.key] == Defaults.EnvironmentCI.trueValue {
                fetchInput = .environmentVariable
            } else {
                fetchInput = Input(input)
            }

            Engine().createFiles(configuration: mappedConfig, input: fetchInput)
        } catch {
            logger.log(.parser, "Error when parsing \(config, color: .blue): \(error, color: .red)")
        }
    }
}

extension Input {
    init(_ input: Retrieve.FetchInput) {
        switch input {
        case .env: self = .environmentVariable
        case .envOrStdin: self = .environmentOrStandardInput
        }
    }
}
