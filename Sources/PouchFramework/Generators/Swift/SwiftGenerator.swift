public struct SwiftGenerator {
    private struct SecretVariable {
        let name: String
        let type: String
        let value: String
        let encryptedValue: String

        func toFullDeclaration() -> String {
            return "static let \(name): \(type) = \(encryptedValue)"
        }

        func toDictionaryDeclaration() -> String {
            return "\"\(name)\": \(encryptedValue),"
        }
    }
    
    public init() {}
    
    public func generateFileContents(secrets: [Secret], representation: OutputRepresentation, config: SwiftConfig) -> String {
        var imports = [String]()
        var functions = [String]()
        var variables = [SecretVariable]()

        for secret in secrets {
            let cipher = cipherGenerator(for: secret)
            let encryptedValue = cipher.variableValue(for: secret, config: config)
            let variable = SecretVariable(
                name: secret.generatedName ?? representation.generateName(for: secret.name),
                type: "String",
                value: secret.value,
                encryptedValue: encryptedValue
            )

            imports.append(contentsOf: cipher.neededImports())
            functions.append(contentsOf: cipher.neededHelperFunctions())
            variables.append(variable)
        }

        let variablesString = switch representation {
        case .dictionary:
            """
    public static var dictionary: [String: String] = [
\(variables.map { "        " +  $0.toDictionaryDeclaration() }.joined(separator: "\n"))
    ]
"""
        case .staticVariables:
            """
\(variables.map { "    " + $0.toFullDeclaration() }.joined(separator: "\n"))
"""
        }

        return
"""
// swiftlint:disable all
// Generated using Pouch — https://github.com/sunshinejr/Pouch

\(imports.unique().map { "import \($0)" }.joined(separator: "\n"))

public enum \(config.typeName) {
\(variablesString)

\(functions.unique().joined(separator: "\n\n"))
}\n
"""
    }
    
    private func cipherGenerator(for secret: Secret) -> SwiftCipherContentsGenerating {
        switch secret.encryption {
        case .xor:
            return SwiftXorGenerator()
        }
    }
}

