import Foundation

public protocol VariableFetching {
    func fetch(secrets: [SecretDeclaration], completion: (Result<[Secret], Error>) -> Void)
}
