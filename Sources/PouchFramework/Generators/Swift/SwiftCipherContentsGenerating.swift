import Foundation

public protocol SwiftCipherContentsGenerating {
    func variableValue(for key: Key, config: SwiftConfig) -> String
    func neededImports() -> [String]
    func neededHelperFunctions() -> [String]
}
