import ArgumentParser

struct Pouch: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility tool for generating secrets file",
        version: "1.0.0",
        subcommands: [Setup.self, Retrieve.self]
    )
}

struct Setup: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Setup a new project to use with Pouch.")
}

struct Retrieve: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Retrieve secrets & generate a file to use them in a project.")
}
