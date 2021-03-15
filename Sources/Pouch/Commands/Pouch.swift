import ArgumentParser
import Foundation

struct Pouch: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility tool for generating secrets file",
        version: "0.0.1",
        subcommands: [Retrieve.self]
    )
}
