import ArgumentParser
import Foundation
import PouchFramework

@main public struct Pouch: AsyncParsableCommand {
    public static var configuration = CommandConfiguration(
        abstract: "A utility tool for secret management",
        version: "0.4.0",
        subcommands: [Retrieve.self],
        defaultSubcommand: Retrieve.self
    )

    public init() {}
}
