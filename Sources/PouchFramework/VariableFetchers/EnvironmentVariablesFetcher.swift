import Foundation

public struct EnvironmentVariableFetcher: VariableFetching {
    public func fetch(secrets: [SecretDeclaration]) async throws -> [Secret] {
        let environment = ProcessInfo.processInfo.environment
        var resolvedSecrets = [Secret]()
        for secret in secrets {
            guard let value = environment[secret.name] else {
                throw VariableFetchingError.variableNotFound(name: secret.name, input: .environmentVariable)
            }
            
            resolvedSecrets.append(secret.with(value: value))
        }
        return resolvedSecrets
    }
}
