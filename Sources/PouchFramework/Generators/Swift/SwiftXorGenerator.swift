import Foundation

public struct SwiftXorGenerator: SwiftCipherContentsGenerating {
    public func variableValue(for secret: Secret, config: SwiftConfig) -> String {
        let salt = [UInt8].random(length: 64)
        let xoredValue = xorEncode(secret: secret.value, salt: salt)
        return "\(config.typeName)._xored(\(xoredValue), salt: \(salt))"
    }
    
    public func neededHelperFunctions() -> [String] {
        return
["""
    private static func _xored(_ secret: [UInt8], salt: [UInt8]) -> String {
        return String(bytes: secret.enumerated().map { index, character in
            return character ^ salt[index % salt.count]
        }, encoding: .utf8) ?? ""
    }
"""]
    }
    
    public func neededImports() -> [String] {
        return ["Foundation"]
    }
    
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
