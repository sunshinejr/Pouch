import ArgumentParser
import PouchFramework

struct Pouch: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility tool for generating secrets file",
        version: "1.0.0",
        subcommands: [Retrieve.self]
    )
}


struct Retrieve: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Retrieve secrets & generate files at given paths with given configuration.")
    
    func run() throws {
        let configuration = Configuration(input: .environmentVariable, secrets: [.init(name: "API_KEY", encryption: .xor)], outputs: [.init(decryptionFile: .init(fileName: "./Secrets.swift"), outputLanguage: .swift(.init(typeName: "Secrets")))])
        Engine().createFiles(configuration: configuration)
    }
}

Pouch.main()
