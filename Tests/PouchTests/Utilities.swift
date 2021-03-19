import Foundation

extension URL {
    /// Returns path to the built products directory.
    public static var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }
}

extension String {
    func removing(suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        
        let endIndex = index(self.endIndex, offsetBy: -suffix.count)
        return String(self[..<endIndex])
    }
    
    func saveToTemporaryDirectory() throws -> URL {
        let url = URL.documentsDirectory.appendingPathComponent("Temp\(Int.random(in: 0...10_000))")
        try write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}

enum Tool {
    case swift
    case pouch
    
    var executableURL: URL {
        switch self {
        case .swift:
            return URL(fileURLWithPath: "/usr/bin/swift")
        case .pouch:
            return URL.productsDirectory.appendingPathComponent("Pouch")
        }
    }
}

extension Process {
    @discardableResult
    static func run(tool: Tool, arguments: [String]? = nil, environmentVariables: [String: String]? = nil) throws -> String {
        let process = Process()
        process.executableURL = tool.executableURL
        process.environment = ProcessInfo.processInfo.environment
        for (key, value) in environmentVariables ?? [:] {
            process.environment?[key] = value
        }
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return (String(data: data, encoding: .utf8) ?? "").removing(suffix: "\n")
    }
}
