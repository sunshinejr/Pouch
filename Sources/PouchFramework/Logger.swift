import Foundation

public var logger: Logging = Logger(output: .disabled)

public extension LogCategory {
    static let parser = LogCategory(name: "Parser")
    static let variableFetcher = LogCategory(name: "VariableFetcher")
    static let fileWriter = LogCategory(name: "FileWriter")
}

public protocol Logging {
    func log(_ message: String)
    func log(_ category: LogCategory, _ message: String)
}

public struct LogCategory {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct Logger: Logging {
    public enum Output {
        case print
        case disabled
    }
    
    public var output: Output
    
    public init(output: Output) {
        self.output = output
    }
    
    public func log(_ category: LogCategory, _ message: String) {
        _log(category: category, message)
    }
    
    public func log(_ message: String) {
        _log(message)
    }
    
    private func _log(category: LogCategory? = nil, _ message: String) {
        switch output {
        case .print:
            if let category = category {
                print("\("[\(category.name)]", color: .yellow) \(message)")
            } else {
                print("\(message)")
            }
        case .disabled:
            break
        }
    }
}
