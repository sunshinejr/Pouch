public struct SwiftGenerator {
    private struct SecretVariable {
        let name: String
        let type: String
        let value: String
        let encryptedValue: String

        func toFullDeclaration(isStatic: Bool) -> String {
            let staticString = isStatic ? "static " : ""
            return "\(staticString)let \(name): \(type) = \(encryptedValue)"
        }

        func toDictionaryDeclaration() -> String {
            return "\"\(name)\": \(encryptedValue),"
        }
    }
    
    public init() {}
    
    public func generateFileContents(keys: [Key], config: SwiftConfig) -> String {
        var imports = [String]()
        var functions = [String]()
        var variables = [SecretVariable]()

        for key in keys {
            let cipher = cipherGenerator(for: config.encryption)
            let encryptedValue = cipher.variableValue(for: key, config: config)
            let name = config.keyMapping[key.name] ?? config.representation.generateName(for: key.name)
            let variable = SecretVariable(
                name: name,
                type: "String",
                value: key.value,
                encryptedValue: encryptedValue
            )

            imports.append(contentsOf: cipher.neededImports())
            functions.append(contentsOf: cipher.neededHelperFunctions())
            variables.append(variable)
        }

        let accessLevelString = switch config.accessLevel {
        case .public: "public "
        case .internal: ""
        case .private: "private "
        case .fileprivate: "fileprivate "
        }

        if !config.isStatic {
            functions.insert(
"""
    \(accessLevelString)init() {}
""", at: 0)
        }

        let staticString = config.isStatic ? "static" : ""

        let variablesString = switch config.representation {
        case .dictionary:
            """
    \(accessLevelString)\(staticString) var dictionary: [String: String] = [
\(variables.map { "        " +  $0.toDictionaryDeclaration() }.joined(separator: "\n"))
    ]
"""
        case .variables:
            """
\(variables.map { "    " + accessLevelString + $0.toFullDeclaration(isStatic: config.isStatic) }.joined(separator: "\n"))
"""
        }

        let importsString: String = if imports.isEmpty {
            ""
        } else {
            """
            
            \(imports.unique().map { "import \($0)" }.joined(separator: "\n"))
            
            """
        }

        let implementationsString: String = if config.implementations.isEmpty {
            ""
        } else {
            ": \(config.implementations.unique().joined(separator: ", "))"
        }

        let typeDeclarationString = if config.isStatic {
            "enum"
        } else {
            "struct"
        }

        let helperFunctionsString: String = if functions.isEmpty {
            ""
        } else {
            """
            
            
            \(functions.unique(identifying: { $0 == $1 }).joined(separator: "\n\n"))
            """
        }


        return
"""
// swiftlint:disable all
// Generated using Pouch — https://github.com/sunshinejr/Pouch
\(importsString)
\(accessLevelString)\(typeDeclarationString) \(config.typeName)\(implementationsString) {
\(variablesString)\(helperFunctionsString)
}\n
"""
    }
    
    private func cipherGenerator(for encryption: Cipher) -> SwiftCipherContentsGenerating {
        switch encryption {
        case .xor:
            return SwiftXorGenerator()
        case .none:
            return SwiftNoneGenerator()
        }
    }
}

