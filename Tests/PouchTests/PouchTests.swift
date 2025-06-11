import XCTest
import PouchFramework

final class PouchTests: XCTestCase {
    func test_showsHelp() throws {
        let output = try Process.run(tool: .pouch, arguments: ["-h"])
        XCTAssertTrue(output.contains("A utility tool for secret management"))
    }

    func test_generatesFileBasedOnConfig() throws {
        let secretApiKey = "secret_sauce_monke_boi🐒"
        let tempDir = FileManager.default.temporaryDirectory
        let generatedFileUrl = tempDir.appendingPathComponent("Secrets2.swift")
        let config = """
keys:
- name: API_KEY_4
input:
  type: env
outputs:
- filePath: \(generatedFileUrl.path)
  typeName: Sauce
"""
        let configFile = try config.saveToTemporaryDirectory()
        let pouchOutput = try Process.run(tool: .pouch, arguments: ["retrieve", "--config", configFile.path], environmentVariables: ["API_KEY_4": secretApiKey])
        print("Pouch output: \(pouchOutput)")
        let generatedFileContents = try String(contentsOfFile: generatedFileUrl.path)
        let generatedFileContentsWithPrint = generatedFileContents + "\n print(Sauce.apiKey4)"
        try generatedFileContentsWithPrint.write(toFile: generatedFileUrl.path, atomically: true, encoding: .utf8)
        
        let output = try Process.run(tool: .swift, arguments: [generatedFileUrl.path])
        XCTAssertEqual(output, secretApiKey)
    }

    static var allTests = [
        ("test_showHelpOnMainCall", test_showsHelp),
        ("test_generatesFileBasedOnConfig", test_generatesFileBasedOnConfig)
    ]
}
