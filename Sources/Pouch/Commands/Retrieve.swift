import ArgumentParser
import Foundation
import PouchFramework
import Yams

public struct Retrieve: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Retrieve secrets & generate files at given paths with given configuration.")
    
    @Option(help: "The config file used to generate the files.")
    var config: String = "./.pouch.yml"

    @Flag(name: .long, help: "Print resolved secrets in console.")
    var printSecrets: Bool = false

    public init() {}
    
    public func run() async throws {
        let logger = Logger(output: .print)
        do {
            // Since we cannot extend YAMLDecoder to attach a logger, work around that by setting a global logger property.
            PouchFramework.logger = logger
            logger.log(.parser, "Reading \(config, color: .green)...")
            let config = try String(contentsOf: URL(fileURLWithPath: self.config))
            let mappedConfig: Configuration = try YAMLDecoder().decode(from: config)
            logger.log(.parser, "\(self.config, color: .green) parsed successfully!")
            await Engine().createFiles(configuration: mappedConfig, printSecrets: printSecrets)
        } catch {
            logger.log(.parser, "Error when parsing \(config, color: .blue): \(error, color: .red)")
        }
    }
}
