import XCTest
import PouchFramework
import Yams

final class ConfigurationParsingTests: XCTestCase {
    func test_noOutput_noConfiguration() {
        let config =
"""
secrets:
- API_KEY
"""
        let parsedConfiguration = try? YAMLDecoder().decode(Configuration.self, from: Data(config.utf8))
        XCTAssertNil(parsedConfiguration)
    }
    
    func test_noSecrets_noConfiguration() {
        let config =
"""
outputs:
- ./Secrets.swift
"""
        let parsedConfiguration = try? YAMLDecoder().decode(Configuration.self, from: Data(config.utf8))
        XCTAssertNil(parsedConfiguration)
    }
    
    func test_hasAtLeastOneSecretAndOneOutput_parsesSuccessfully() {
        let config =
"""
secrets:
- API_KEY
outputs:
- ./Secrets.swift
"""
        let parsedConfiguration = try? YAMLDecoder().decode(Configuration.self, from: Data(config.utf8))
        let expectedConfiguration = Configuration(
            input: Defaults.input,
            secrets: [
                .init(name: "API_KEY", encryption: Defaults.encryption)
            ],
            outputs: [
                .init(decryptionFile: .init(filePath: "./Secrets.swift"), outputLanguage: .swift(.init(typeName: Defaults.Swift.typeName)))
            ])
        XCTAssertEqual(parsedConfiguration, expectedConfiguration)
    }
}

extension ConfigurationParsingTests {
    static var allTests = [
        ("test_noOutput_noConfiguration", test_noOutput_noConfiguration),
        ("test_noSecrets_noConfiguration", test_noSecrets_noConfiguration),
        ("test_hasAtLeastOneSecretAndOneOutput_parsesSuccessfully", test_hasAtLeastOneSecretAndOneOutput_parsesSuccessfully)
    ]
}
