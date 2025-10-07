import XCTest
import PouchFramework

final class SwiftGeneratorTests: XCTestCase {
    func test_generatedOutput() throws {
        let key = Key(name: "API_KEYY", value: "secret_sauce_monke_boi🐒")
        let config = SwiftConfig(accessLevel: .public, typeName: "Sauce", isStatic: true, implementations: [], encryption: .xor, representation: .variables)
        let contents = SwiftGenerator().generateFileContents(keys: [key], config: config)
        let contentsWithPrints = contents + "\n print(\(config.typeName).apiKeyy)"
        let file = try contentsWithPrints.saveToTemporaryDirectory()
        let output = try Process.run(tool: .swift, arguments: [file.path])
        
        XCTAssertEqual(output, key.value)
    }
    
    func test_generatedNameIsUsed() throws {
        let key = Key(name: "API_KEY", value: "test_secret_value", generatedName: "youtubeApiKey")
        let config = SwiftConfig(accessLevel: .public, typeName: "Secrets", isStatic: true, implementations: [], encryption: .xor, representation: .variables)
        let contents = SwiftGenerator().generateFileContents(keys: [key], config: config)
        let contentsWithPrints = contents + "\n print(\(config.typeName).youtubeApiKey)"
        let file = try contentsWithPrints.saveToTemporaryDirectory()
        let output = try Process.run(tool: .swift, arguments: [file.path])
        
        XCTAssertEqual(output, key.value)
    }
    
    func test_generatedNameTakesPrecedenceOverCamelCase() throws {
        let key = Key(name: "API_KEY", value: "test_value", generatedName: "customName")
        let config = SwiftConfig(accessLevel: .public, typeName: "Secrets", isStatic: true, implementations: [], encryption: .none, representation: .variables)
        let contents = SwiftGenerator().generateFileContents(keys: [key], config: config)
        
        // Should contain customName, not apiKey
        XCTAssertTrue(contents.contains("let customName:"))
        XCTAssertFalse(contents.contains("let apiKey:"))
    }
}
