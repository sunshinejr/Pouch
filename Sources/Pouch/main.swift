import ArgumentParser
import Foundation
import PouchFramework
import Yams

let logger = Logger(output: .print)

struct Pouch: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility tool for generating secrets file",
        version: "1.0.0",
        subcommands: [Retrieve.self]
    )
}

struct Retrieve: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Retrieve secrets & generate files at given paths with given configuration.")
    
    @Option(help: "The config file used to generate the files.")
    var config: String = "./.pouch.yml"
    
    func run() throws {
        do {
            // Since we cannot extend YAMLDecoder to attach a logger, work around that by setting a global logger property.
            PouchFramework.logger = logger
            logger.log(.parser, "Reading \(config, color: .green)...")
            let config = try String(contentsOf: URL(fileURLWithPath: self.config))
            let mappedConfig: Configuration = try YAMLDecoder().decode(from: config)
            logger.log(.parser, "\(self.config, color: .green) parsed successfully!")
            Engine().createFiles(configuration: mappedConfig)
        } catch {
            logger.log(.parser, "Error when parsing \(config, color: .blue): \(error, color: .red)")
        }
    }
}

Pouch.main()
