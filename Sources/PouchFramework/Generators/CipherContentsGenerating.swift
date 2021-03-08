import Foundation

public protocol CipherContentsGenerating {
    associatedtype LanguageConfig
    
    func variableValue(for secret: Secret, config: LanguageConfig) -> String
    func neededImports() -> [String]
    func neededHelperFunctions() -> [String]
}

public protocol SwiftCipherContentsGenerating: CipherContentsGenerating where LanguageConfig == SwiftConfig {}
