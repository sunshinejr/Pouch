import ArgumentParser
import Foundation
import PouchFramework
import Yams

struct Pouch: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility tool for generating secrets file",
        version: "1.0.0",
        subcommands: [Retrieve.self]
    )
}

struct Retrieve: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Retrieve secrets & generate files at given paths with given configuration.")
    
    @Option(help: "The config file used to generate the files.")
    var config: String = "./.pouch.yml"
    
    func run() throws {
        do {
            let config = try String(contentsOf: URL(fileURLWithPath: self.config))
            let mappedConfig: Configuration = try YAMLDecoder().decode(from: config)
            let string = try YAMLEncoder().encode(mappedConfig)
            Engine().createFiles(configuration: mappedConfig)
            print("Using configuration:")
            print(string)
        } catch {
            print("Error when decoding string: \(error)")
        }
    }
}

Pouch.main()
