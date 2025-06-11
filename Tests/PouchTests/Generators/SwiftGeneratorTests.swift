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
}
