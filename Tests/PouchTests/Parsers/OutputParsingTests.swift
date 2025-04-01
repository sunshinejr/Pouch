import XCTest
import PouchFramework
import Yams

final class OutputParsingTests: XCTestCase {
    func test_namedParameters_withFilePathOnly_parsesSuccessfully() {
        let config =
"""
- filePath: ./Secrets.swift
"""
        let parsedOutputs = try? YAMLDecoder().decode([Output].self, from: Data(config.utf8))
        let expectedOutputs = [
            Output(decryptionFile: .init(filePath: "./Secrets.swift"), representation: .staticVariables, outputLanguage: .swift(.init(typeName: Defaults.Swift.typeName)))
        ]
        XCTAssertEqual(parsedOutputs, expectedOutputs)
    }
    
    func test_namedParameters_withFilePathAndTypeName_parsesSuccessfully() throws {
        let config =
"""
- filePath: ./Sauce.swift
  typeName: Sauce
  representation: staticVariables
"""
        let parsedOutputs = try YAMLDecoder().decode([Output].self, from: Data(config.utf8))
        let expectedOutputs = [
            Output(decryptionFile: .init(filePath: "./Sauce.swift"), representation: .staticVariables, outputLanguage: .swift(.init(typeName: "Sauce")))
        ]
        XCTAssertEqual(parsedOutputs, expectedOutputs)
    }
    
    func test_multipleSecrets_withBothSingleStringAndNamedParameters_parsesSuccessfully() {
        let config =
"""
- ./Secrets.swift
- filePath: ./Sauce.swift
  typeName: Sauce
"""
        let parsedOutputs = try? YAMLDecoder().decode([Output].self, from: Data(config.utf8))
        let expectedOutputs = [
            Output(decryptionFile: .init(filePath: "./Secrets.swift"), representation: .staticVariables, outputLanguage: .swift(.init(typeName: Defaults.Swift.typeName))),
            Output(decryptionFile: .init(filePath: "./Sauce.swift"), representation: .staticVariables, outputLanguage: .swift(.init(typeName: "Sauce")))
        ]
        XCTAssertEqual(parsedOutputs, expectedOutputs)
    }

    func test_outputRepresentation_withNamedParameters_parsesSuccessfully() throws {
        let config =
"""
- ./Secrets.swift
- filePath: ./SecretsDictionary.swift
  typeName: SecretsDictionary
  representation: dictionary
"""
        let parsedOutputs = try YAMLDecoder().decode([Output].self, from: Data(config.utf8))
        let expectedOutputs = [
            Output(decryptionFile: .init(filePath: "./Secrets.swift"), representation: .staticVariables, outputLanguage: .swift(.init(typeName: Defaults.Swift.typeName))),
            Output(decryptionFile: .init(filePath: "./SecretsDictionary.swift"), representation: .dictionary, outputLanguage: .swift(.init(typeName: "SecretsDictionary")))
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
