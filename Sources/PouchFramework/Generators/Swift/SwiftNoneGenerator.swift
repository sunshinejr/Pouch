public struct SwiftNoneGenerator: SwiftCipherContentsGenerating {
    public func neededImports() -> [String] { [] }

    public func neededHelperFunctions() -> [String] { [] }

    public func variableValue(for key: Key, config: SwiftConfig) -> String {
        return "\"\(key.value)\""
    }
}
