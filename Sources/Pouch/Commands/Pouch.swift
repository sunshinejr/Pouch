import ArgumentParser
import Foundation

public struct Pouch: ParsableCommand {
    public static var configuration = CommandConfiguration(
        abstract: "A utility tool for secret management",
        version: "0.1.0",
        subcommands: [Retrieve.self],
        defaultSubcommand: Retrieve.self
    )
    
    public init() {}
}
