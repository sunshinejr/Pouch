import ArgumentParser
import Foundation
import PouchFramework
import Yams

public struct Retrieve: AsyncParsableCommand {
    public static let configuration =
        CommandConfiguration(abstract: "Retrieve secrets & generate files at given paths with given configuration.")

    @Option(help: "The config file used to generate the files.")
    var config: String?

    @Flag(name: .long, help: "Print resolved secrets in console.")
    var printSecrets: Bool = false

    public init() {}

    public func run() async throws {
        let logger = Logger(output: .print)
        // Since we cannot extend YAMLDecoder to attach a logger, work around that by setting a global logger property.
        PouchFramework.logger = logger
        logger.log(.parser, "Reading config files...")
        let mappedConfigs: [String: Configuration]
        do {
            if let config = config, !config.isEmpty {
                let url = URL(fileURLWithPath: config)
                logger.log(.parser, "Reading config from: \(url.lastPathComponent)")
                let configString = try String(contentsOf: url)
                let mappedConfig: Configuration = try YAMLDecoder().decode(from: configString)
                mappedConfigs = [config: mappedConfig]
            } else {
                let currentDirectoryPath = FileManager.default.currentDirectoryPath
                mappedConfigs = try FileManager.default.contentsOfDirectory(
                    at: URL(fileURLWithPath: currentDirectoryPath),
                    includingPropertiesForKeys: nil,
                    options: .skipsHiddenFiles
                )
                .filter { $0.lastPathComponent.hasSuffix(".pouch.yml") }
                .compactMap { try ($0, String(contentsOf: $0)) }
                .reduce(into: [String: Configuration]()) { result, object in
                    logger.log(.parser, "Reading config from: \(object.0.lastPathComponent)")
                    result[object.0.lastPathComponent] = try YAMLDecoder().decode(from: object.1)
                }
            }
        } catch {
            logger.log(.parser, "Error reading config file: \(error, color: .red)")
            mappedConfigs = [:]
        }

        if mappedConfigs.isEmpty {
            logger.log(.parser, "\("No configurations found, exiting.", color: .red)")
        } else {
            logger.log(.parser, "\("Configs parsed successfully!", color: .green)")
            logger.log(.parser, "(\(mappedConfigs.keys.joined(separator: ","), color: .green))")
            let engine = Engine()
            for (filePath, mappedConfig) in mappedConfigs {
                logger.log(.parser, "Processing configuration for \(filePath, color: .blue)...")
                await engine.createFiles(configuration: mappedConfig, printSecrets: printSecrets)
            }
        }
    }
}
