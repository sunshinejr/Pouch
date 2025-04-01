import Foundation

public protocol VariableFetching {
    func fetch(secrets: [SecretDeclaration]) async throws -> [Secret]
}
