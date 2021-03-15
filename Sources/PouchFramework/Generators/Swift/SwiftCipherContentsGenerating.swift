import Foundation

public protocol SwiftCipherContentsGenerating {
    func variableValue(for secret: Secret, config: SwiftConfig) -> String
    func neededImports() -> [String]
    func neededHelperFunctions() -> [String]
}
