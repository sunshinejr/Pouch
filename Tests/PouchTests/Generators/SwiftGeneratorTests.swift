import XCTest
import PouchFramework

final class SwiftGeneratorTests: XCTestCase {
    func test_generatedOutput() throws {
        let secret = Secret(name: "API_KEYY", generatedName: "apiKey", value: "secret_sauce_monke_boi🐒", encryption: .xor)
        let config = SwiftConfig(typeName: "Sauce")
        let contents = SwiftGenerator().generateFileContents(secrets: [secret], config: config)
        let contentsWithPrints = contents + "\n print(\(config.typeName).\(secret.generatedName!))"
        let file = try contentsWithPrints.saveToTemporaryDirectory()
        let output = try Process.run(tool: .swift, arguments: [file.path])
        
        XCTAssertEqual(output, secret.value)
    }
}
