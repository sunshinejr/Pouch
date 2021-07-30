import Foundation

public struct EnvironmentOrStdinVariableFetcher: VariableFetching {
    public func fetch(secrets: [SecretDeclaration], completion: (Result<[Secret], Error>) -> Void) {
        let environment = ProcessInfo.processInfo.environment
        var resolvedSecrets = [Secret]()
        for secret in secrets {
            do {
                let value = try retrieveValue(secret: secret, from: environment)
                resolvedSecrets.append(secret.with(value: value))
            } catch {
                do {
                    let value = try readValueFromInput(secret: secret)
                    resolvedSecrets.append(secret.with(value: value))
                } catch {
                    completion(.failure(VariableFetchingError.variableNotFound(name: secret.name, input: .environmentVariable)))
                    return
                }
            }
        }

        completion(.success(resolvedSecrets))
    }

    func retrieveValue(
        secret: SecretDeclaration,
        from environment: [String: String]
    ) throws -> String {
        guard let value = environment[secret.name] else {
            throw VariableFetchingError.variableNotFound(name: secret.name, input: .environmentOrStandardInput)
        }
        return value
    }

    func readValueFromInput(secret: SecretDeclaration) throws -> String {
        logger.log(.variableFetcher, "Enter value for \(secret.name) secret")
        let value = readLine()
        guard let value = value, value.isNotEmpty else {
            throw VariableFetchingError.variableNotFound(name: secret.name, input: .environmentOrStandardInput)
        }
        return value
    }
}
