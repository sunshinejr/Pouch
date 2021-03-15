struct SwiftGenerator {
    private struct SecretVariable {
        let name: String
        let type: String
        let value: String
        
        func toFullDeclaration() -> String {
            return "static let \(name): \(type) = \(value)"
        }
    }
    
    public init() {}
    
    public func generateFileContents(secrets: [Secret], config: SwiftConfig) -> String {
        var imports = [String]()
        var functions = [String]()
        var variables = [SecretVariable]()
        
        for secret in secrets {
            let cipher = cipherGenerator(for: secret)
            let value = cipher.variableValue(for: secret, config: config)
            let variable = SecretVariable(
                name: secret.generatedName ?? secret.name.toCamelCase(),
                type: "String",
                value: value
            )
            
            imports.append(contentsOf: cipher.neededImports())
            functions.append(contentsOf: cipher.neededHelperFunctions())
            variables.append(variable)
        }

        return
"""
\(imports.unique().map { "import \($0)" }.joined(separator: "\n"))

enum \(config.typeName) {
\(variables.map { "   " + $0.toFullDeclaration() }.joined(separator: "\n"))

\(functions.unique().joined(separator: "\n\n"))
}
"""
    }
    
    private func cipherGenerator(for secret: Secret) -> SwiftCipherContentsGenerating {
        switch secret.encryption {
        case .xor:
            return SwiftXorGenerator()
        }
    }
}

