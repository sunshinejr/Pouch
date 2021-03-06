struct SwiftGenerator: FileContentsGenerating {
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
        let mappedVariables = secrets.map { secret -> SecretVariable in
            let salt = [UInt8].random(length: 64)
            let xoredValue = xorEncode(secret: secret.value, salt: salt)
            return SecretVariable(
                name: secret.name.toCamelCase(),
                type: "String",
                value: "\(config.typeName)._xored(\(xoredValue), salt: \(salt))"
            )
        }
        
        return
"""
import Foundation

enum \(config.typeName) {
    \(mappedVariables.map { $0.toFullDeclaration() }.joined(separator: "\n"))

    private static func _xored(_ secret: [UInt8], salt: [UInt8]) -> String {
        return String(bytes: secret.enumerated().map { index, character in
            return character ^ salt[index % salt.count]
        }, encoding: .utf8) ?? ""
    }
}
"""
    }
    
    // Extract to a external XorCipher type?
    private func xorEncode(secret: String, salt: [UInt8]) -> [UInt8] {
        let secretBytes = [UInt8](secret.utf8)
        return secretBytes.enumerated().map { index, character in
            return character ^ salt[index % salt.count]
        }
    }

    private func xorDecode(encoded secretBytes: [UInt8], salt: [UInt8]) -> String {
        return String(bytes: secretBytes.enumerated().map { index, character in
            return character ^ salt[index % salt.count]
        }, encoding: .utf8) ?? ""
    }
}
