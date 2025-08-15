import Foundation

public struct EnvironmentVariableFetcher {
    public func fetch(declarations: [KeyDeclaration], keyMapping: [String: String]) async throws -> [Key] {
        let environment = ProcessInfo.processInfo.environment
        var resolvedKeys = [Key]()
        for declaration in declarations {
            let mappedKey = keyMapping[declaration.name] ?? declaration.name
            guard let value = environment[mappedKey] else {
                throw VariableFetchingError.variableNotFound(name: declaration.name, input: .environmentVariable(keyMapping))
            }
            
            resolvedKeys.append(declaration.with(value: value))
        }
        return resolvedKeys
    }
}
