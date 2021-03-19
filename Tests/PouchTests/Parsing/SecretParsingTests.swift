import XCTest
import PouchFramework
import Yams

final class SecretParsingTests: XCTestCase {
    func test_namedParameters_withNameOnly_parsesSuccessfully() {
        let config =
"""
- name: API_KEY2
"""
        let parsedSecrets = try? YAMLDecoder().decode([SecretDeclaration].self, from: Data(config.utf8))
        let expectedSecrets = [SecretDeclaration(name: "API_KEY2", encryption: Defaults.encryption)]
        XCTAssertEqual(parsedSecrets, expectedSecrets)
    }
    
    
    func test_namedParameters_withNameAndGeneratedName_parsesSuccessfully() {
        let config =
"""
- name: API_KEY2
  generatedName: apiKeyuu
"""
        let parsedSecrets = try? YAMLDecoder().decode([SecretDeclaration].self, from: Data(config.utf8))
        let expectedSecrets = [SecretDeclaration(name: "API_KEY2", generatedName: "apiKeyuu", encryption: Defaults.encryption)]
        XCTAssertEqual(parsedSecrets, expectedSecrets)
    }
    
    func test_multipleSecrets_withBothSingleStringAndNamedParameters_parsesSuccessfully() {
        let config =
"""
- API_KEY
- name: API_KEY2
  generatedName: apiKeyuu
"""
        let parsedSecrets = try? YAMLDecoder().decode([SecretDeclaration].self, from: Data(config.utf8))
        let expectedSecrets = [
            SecretDeclaration(name: "API_KEY", encryption: Defaults.encryption),
            SecretDeclaration(name: "API_KEY2", generatedName: "apiKeyuu", encryption: Defaults.encryption)
        ]
        XCTAssertEqual(parsedSecrets, expectedSecrets)
    }
}

extension SecretParsingTests {
    static var allTests = [
        ("test_namedParameters_withNameOnly_parsesSuccessfully", test_namedParameters_withNameOnly_parsesSuccessfully),
        ("test_namedParameters_withNameAndGeneratedName_parsesSuccessfully", test_namedParameters_withNameAndGeneratedName_parsesSuccessfully),
        ("test_multipleSecrets_withBothSingleStringAndNamedParameters_parsesSuccessfully", test_multipleSecrets_withBothSingleStringAndNamedParameters_parsesSuccessfully)
    ]
}
