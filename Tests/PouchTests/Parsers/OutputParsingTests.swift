import XCTest
import PouchFramework
import Yams

final class OutputParsingTests: XCTestCase {
    func test_namedParameters_withFilePathOnly_parsesSuccessfully() {
        let config =
"""
- filePath: ./Secrets.swift
  representation: variables
"""
        let parsedOutputs = try? YAMLDecoder().decode([Output].self, from: Data(config.utf8))
        let expectedOutputs = [
            Output(file: .init(filePath: "./Secrets.swift"), outputLanguage: .swift(.init(accessLevel: Defaults.Swift.accessLevel, typeName: Defaults.Swift.typeName, isStatic: true, implementations: Defaults.Swift.implementations, encryption: .xor, representation: .variables)))
        ]
        XCTAssertEqual(parsedOutputs, expectedOutputs)
    }
    
    func test_namedParameters_withFilePathAndTypeName_parsesSuccessfully() throws {
        let config =
"""
- filePath: ./Sauce.swift
  typeName: Sauce
  isStatic: true
  representation: variables
  implementations: [SecretProviding]
  keyMapping: 
    appsflyer: appsFlyer
"""
        let parsedOutputs = try YAMLDecoder().decode([Output].self, from: Data(config.utf8))
        let expectedOutputs = [
            Output(file: .init(filePath: "./Sauce.swift"), outputLanguage: .swift(.init(accessLevel: Defaults.Swift.accessLevel, typeName: "Sauce", isStatic: true, implementations: ["SecretProviding"], encryption: Defaults.Swift.encryption, representation: Defaults.Swift.representation, keyMapping: ["appsflyer": "appsFlyer"])))
        ]
        XCTAssertEqual(parsedOutputs, expectedOutputs)
    }
    
    func test_multipleSecrets_withBothSingleStringAndNamedParameters_parsesSuccessfully() {
        let config =
"""
- ./Secrets.swift
- filePath: ./Sauce.swift
  typeName: Sauce
  isStatic: false
"""
        let parsedOutputs = try? YAMLDecoder().decode([Output].self, from: Data(config.utf8))
        let expectedOutputs = [
            Output(file: .init(filePath: "./Secrets.swift"), outputLanguage: .swift(.init(accessLevel: Defaults.Swift.accessLevel, typeName: Defaults.Swift.typeName, isStatic: true, implementations: Defaults.Swift.implementations, encryption: Defaults.Swift.encryption, representation: Defaults.Swift.representation))),
            Output(file: .init(filePath: "./Sauce.swift"), outputLanguage: .swift(.init(accessLevel: Defaults.Swift.accessLevel, typeName: "Sauce", isStatic: false, implementations: Defaults.Swift.implementations, encryption: Defaults.Swift.encryption, representation: Defaults.Swift.representation)))
        ]
        XCTAssertEqual(parsedOutputs, expectedOutputs)
    }

    func test_outputRepresentation_withNamedParameters_parsesSuccessfully() throws {
        let config =
"""
- ./Secrets.swift
- filePath: ./SecretsDictionary.swift
  typeName: SecretsDictionary
  encryption: none
  isStatic: false
  representation: dictionary
  accessLevel: public
"""
        let parsedOutputs = try YAMLDecoder().decode([Output].self, from: Data(config.utf8))
        let expectedOutputs = [
            Output(file: .init(filePath: "./Secrets.swift"), outputLanguage: .swift(.init(accessLevel: Defaults.Swift.accessLevel, typeName: Defaults.Swift.typeName, isStatic: Defaults.Swift.isStatic, implementations: Defaults.Swift.implementations, encryption: Defaults.Swift.encryption, representation: Defaults.Swift.representation))),
            Output(file: .init(filePath: "./SecretsDictionary.swift"), outputLanguage: .swift(.init(accessLevel: .public, typeName: "SecretsDictionary", isStatic: false, implementations: Defaults.Swift.implementations, encryption: .none, representation: .dictionary)))
        ]
        XCTAssertEqual(parsedOutputs, expectedOutputs)
    }
}

extension OutputParsingTests {
    static var allTests = [
        ("test_namedParameters_withFilePathOnly_parsesSuccessfully", test_namedParameters_withFilePathOnly_parsesSuccessfully),
        ("test_namedParameters_withFilePathAndTypeName_parsesSuccessfully", test_namedParameters_withFilePathAndTypeName_parsesSuccessfully),
        ("test_multipleSecrets_withBothSingleStringAndNamedParameters_parsesSuccessfully", test_multipleSecrets_withBothSingleStringAndNamedParameters_parsesSuccessfully)
    ]
}
