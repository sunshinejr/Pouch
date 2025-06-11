import XCTest
import PouchFramework
import Yams

final class ConfigurationParsingTests: XCTestCase {
    func test_noKeys_noConfiguration() {
        let config =
"""
outputs:
- ./Secrets.swift
"""
        let parsedConfiguration = try? YAMLDecoder().decode(Configuration.self, from: Data(config.utf8))
        XCTAssertNil(parsedConfiguration)
    }

    func test_hasAtLeastOneSecret_andInput_AndOutput_thenParsesSuccessfully() throws {
        let config =
"""
keys:
- API_KEY

input:
  type: env
  keyMapping:
    API_KEY: apiKey

outputs:
  - filePath: ./Secrets.swift
    typeName: Secrets
    encryption: xor
"""
        let parsedConfiguration = try YAMLDecoder().decode(Configuration.self, from: Data(config.utf8))
        let expectedConfiguration = Configuration(
            keys: [.init(name: "API_KEY")],
            input: .environmentVariable(["API_KEY": "apiKey"]),
            outputs: [
                .init(
                    file: .init(filePath: "./Secrets.swift"),
                    outputLanguage: .swift(.init(
                        accessLevel: Defaults.Swift.accessLevel,
                        typeName: "Secrets",
                        isStatic: true,
                        implementations: Defaults.Swift.implementations,
                        encryption: Defaults.Swift.encryption,
                        representation: Defaults.Swift.representation
                    ))
                )
            ])
        XCTAssertEqual(parsedConfiguration, expectedConfiguration)
    }
    
    func test_uses_environments() throws {
        let config =
"""
keys:
- APPSTORE_REVIEW_ALERT_DAYS

environments:
  dev:
    input:
      type: firebase
      configPath: ./firebase-dev-config.plist
    outputs:
      - filePath: ./Config-Dev.swift
        typeName: Config
        encryption: none
  prod:
    input:
      type: firebase
      configPath: ./firebase-prod-config.plist
    outputs:
      - filePath: ./Config-Prod.swift
        typeName: Config
        encryption: xor
"""
        let parsedConfiguration = try YAMLDecoder().decode(Configuration.self, from: Data(config.utf8))
        let expectedConfiguration = Configuration(
            keys: [.init(name: "APPSTORE_REVIEW_ALERT_DAYS")],
            input: nil,
            outputs: [],
            environments: [
                "dev": .init(input: .firebaseRemoteConfig("./firebase-dev-config.plist", [:]), outputs: [.init(file: .init(filePath: "./Config-Dev.swift"), outputLanguage: .swift(.init(accessLevel: Defaults.Swift.accessLevel, typeName: "Config", isStatic: true, implementations: Defaults.Swift.implementations, encryption: .none, representation: Defaults.Swift.representation)))]),
                "prod": .init(input: .firebaseRemoteConfig("./firebase-prod-config.plist", [:]), outputs: [.init(file: .init(filePath: "./Config-Prod.swift"), outputLanguage: .swift(.init(accessLevel: Defaults.Swift.accessLevel, typeName: "Config", isStatic: true, implementations: Defaults.Swift.implementations, encryption: .xor, representation: Defaults.Swift.representation)))])
            ]
        )
        XCTAssertEqual(parsedConfiguration, expectedConfiguration)
    }
}
