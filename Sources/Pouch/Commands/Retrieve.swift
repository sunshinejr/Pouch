import ArgumentParser
import Foundation
import PouchFramework
import Yams

public struct Retrieve: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Retrieve secrets & generate files at given paths with given configuration.")
    
    @Option(help: "The config file used to generate the files.")
    var config: String = "./.pouch.yml"

    public init() {}

    public func run() throws {
        do {
            // Since we cannot extend YAMLDecoder to attach a logger, work around that by setting a global logger property.
            PouchFramework.logger = logger
            logger.log(.parser, "Reading \(config, color: .green)...")
            let config = try String(contentsOf: URL(fileURLWithPath: self.config))
            var mappedConfig: Configuration = try YAMLDecoder().decode(from: config)
            logger.log(.parser, "\(self.config, color: .green) parsed successfully!")

            mappedConfig = overrideConfigurationIfRequired(mappedConfig)

            Engine().createFiles(configuration: mappedConfig)
        } catch {
            logger.log(.parser, "Error when parsing \(config, color: .blue): \(error, color: .red)")
        }
    }

    private func overrideConfigurationIfRequired(_ configuration: Configuration) -> Configuration {
        // Pouch should never ask for stdin when command is ran on CI
        if
            configuration.input == .environmentOrStandardInput,
            ProcessInfo.processInfo.environment[Defaults.EnvironmentCI.key] == Defaults.EnvironmentCI.trueValue
        {
            logger.log(.parser, "Overriding input to env because command is used on CI")
            return Configuration(
                input: .environmentVariable,
                secrets: configuration.secrets,
                outputs: configuration.outputs
            )
        }
        return configuration
    }
}
