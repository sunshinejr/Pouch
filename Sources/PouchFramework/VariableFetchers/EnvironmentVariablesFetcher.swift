import Foundation

public struct EnvironmentVariableFetcher: VariableFetching {
    public func fetch(secrets: [SecretDeclaration], completion: (Result<[Secret], Error>) -> Void) {
        let environment = ProcessInfo.processInfo.environment
        var resolvedSecrets = [Secret]()
        for secret in secrets {
            guard let value = environment[secret.name] else {
                completion(.failure(VariableFetchingError.variableNotFound(name: secret.name, input: .environmentVariable)))
                return
            }
            
            resolvedSecrets.append(secret.with(value: value))
        }
        
        completion(.success(resolvedSecrets))
    }
}
