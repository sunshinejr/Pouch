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
    
    func test_onePassword_withAccount_parsesSuccessfully() throws {
        let config =
"""
keys:
- API_KEY
- DATABASE_URL

input:
  type: 1password
  vault: MyVault
  account: my-account@example.com
  section: production
  keyMapping:
    API_KEY: prod_api_key

outputs:
  - filePath: ./Secrets.swift
    typeName: Secrets
"""
        let parsedConfiguration = try YAMLDecoder().decode(Configuration.self, from: Data(config.utf8))
        let expectedConfiguration = Configuration(
            keys: [.init(name: "API_KEY"), .init(name: "DATABASE_URL")],
            input: .onePassword("MyVault", "my-account@example.com", "production", ["API_KEY": "prod_api_key"]),
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
    
    func test_onePassword_withoutAccount_parsesSuccessfully() throws {
        let config =
"""
keys:
- API_KEY

input:
  type: 1password
  vault: MyVault
  section: production

outputs:
  - filePath: ./Secrets.swift
    typeName: Secrets
"""
        let parsedConfiguration = try YAMLDecoder().decode(Configuration.self, from: Data(config.utf8))
        let expectedConfiguration = Configuration(
            keys: [.init(name: "API_KEY")],
            input: .onePassword("MyVault", nil, "production", [:]),
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
    
    func test_keys_withGeneratedName_parsesSuccessfully() throws {
        let config =
"""
keys:
- name: API_KEY
  generatedName: youtubeApiKey
- DATABASE_URL

input:
  type: env

outputs:
  - filePath: ./Secrets.swift
    typeName: Secrets
"""
        let parsedConfiguration = try YAMLDecoder().decode(Configuration.self, from: Data(config.utf8))
        let expectedConfiguration = Configuration(
            keys: [.init(name: "API_KEY", generatedName: "youtubeApiKey"), .init(name: "DATABASE_URL")],
            input: .environmentVariable([:]),
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
}
