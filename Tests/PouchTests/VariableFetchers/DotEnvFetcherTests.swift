import XCTest
@testable import PouchFramework

final class DotEnvFetcherTests: XCTestCase {

    // MARK: - Basic Parsing Tests

    func test_parsesSimpleKeyValuePairs() async throws {
        let envContent = """
        API_KEY=secret123
        DATABASE_URL=postgres://localhost
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "API_KEY"), KeyDeclaration(name: "DATABASE_URL")]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: [:])

        XCTAssertEqual(keys.count, 2)
        XCTAssertEqual(keys[0].value, "secret123")
        XCTAssertEqual(keys[1].value, "postgres://localhost")
    }

    func test_handlesQuotedValues() async throws {
        let envContent = """
        DOUBLE_QUOTED="hello world"
        SINGLE_QUOTED='hello world'
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "DOUBLE_QUOTED"), KeyDeclaration(name: "SINGLE_QUOTED")]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: [:])

        XCTAssertEqual(keys[0].value, "hello world")
        XCTAssertEqual(keys[1].value, "hello world")
    }

    func test_skipsCommentsAndEmptyLines() async throws {
        let envContent = """
        # This is a comment
        API_KEY=secret

        # Another comment
        DATABASE=test
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "API_KEY"), KeyDeclaration(name: "DATABASE")]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: [:])

        XCTAssertEqual(keys.count, 2)
        XCTAssertEqual(keys[0].value, "secret")
        XCTAssertEqual(keys[1].value, "test")
    }

    func test_handlesValuesWithEqualsSign() async throws {
        let envContent = """
        CONNECTION_STRING=host=localhost;port=5432
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "CONNECTION_STRING")]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: [:])

        XCTAssertEqual(keys[0].value, "host=localhost;port=5432")
    }

    func test_handlesKeyMapping() async throws {
        let envContent = """
        MY_CUSTOM_KEY=mapped_value
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "API_KEY")]
        let keyMapping = ["API_KEY": "MY_CUSTOM_KEY"]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: keyMapping)

        XCTAssertEqual(keys[0].value, "mapped_value")
    }

    // MARK: - Variable Interpolation Tests

    func test_interpolatesVariableReferences() async throws {
        let envContent = """
        USERNAME=admin
        EMAIL=${USERNAME}@example.com
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "EMAIL")]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: [:])

        XCTAssertEqual(keys[0].value, "admin@example.com")
    }

    func test_interpolatesMultipleVariablesInSameValue() async throws {
        let envContent = """
        HOST=localhost
        PORT=5432
        CONNECTION=${HOST}:${PORT}
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "CONNECTION")]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: [:])

        XCTAssertEqual(keys[0].value, "localhost:5432")
    }

    func test_handlesNestedVariableReferences() async throws {
        let envContent = """
        BASE=example
        DOMAIN=${BASE}.com
        URL=https://${DOMAIN}/api
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "URL")]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: [:])

        XCTAssertEqual(keys[0].value, "https://example.com/api")
    }

    func test_preservesUnresolvedVariables() async throws {
        let envContent = """
        MESSAGE=Hello ${UNDEFINED_VAR}!
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "MESSAGE")]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: [:])

        // Unresolved variables should be preserved as-is
        XCTAssertEqual(keys[0].value, "Hello ${UNDEFINED_VAR}!")
    }

    // MARK: - Multi-line Value Tests

    func test_parsesMultilineValuesWithDoubleQuotes() async throws {
        let envContent = """
        PRIVATE_KEY=\"\"\"
        -----BEGIN KEY-----
        abc123
        -----END KEY-----
        \"\"\"
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "PRIVATE_KEY")]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: [:])

        let expectedValue = """

        -----BEGIN KEY-----
        abc123
        -----END KEY-----

        """
        XCTAssertEqual(keys[0].value, expectedValue)
    }

    func test_parsesMultilineValuesWithSingleQuotes() async throws {
        let envContent = """
        CERTIFICATE='''
        line1
        line2
        line3
        '''
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "CERTIFICATE")]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: [:])

        let expectedValue = """

        line1
        line2
        line3

        """
        XCTAssertEqual(keys[0].value, expectedValue)
    }

    // MARK: - Integration Test

    func test_comprehensiveEnvFileParsing() async throws {
        let envContent = """
        # Database configuration
        DB_HOST=localhost
        DB_PORT=5432
        DB_USER=admin
        DB_PASSWORD="super_secret_123"

        # Derived connection string using interpolation
        DB_CONNECTION=${DB_HOST}:${DB_PORT}
        DB_URL=postgres://${DB_USER}:${DB_PASSWORD}@${DB_CONNECTION}/mydb

        # App settings with quotes
        APP_NAME='My Test App'
        APP_DESCRIPTION="A great app for testing"

        # Multi-line certificate
        SSL_CERT=\"\"\"
        -----BEGIN CERTIFICATE-----
        MIICpDCCAYwCCQDU+pQ4P2dG3DANBgkqhkiG9w0BAQsFADAUMRIw
        -----END CERTIFICATE-----
        \"\"\"

        # Nested interpolation
        BASE_DOMAIN=example
        FULL_DOMAIN=${BASE_DOMAIN}.com
        API_ENDPOINT=https://${FULL_DOMAIN}/api/v1
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [
            KeyDeclaration(name: "DB_HOST"),
            KeyDeclaration(name: "DB_PORT"),
            KeyDeclaration(name: "DB_USER"),
            KeyDeclaration(name: "DB_PASSWORD"),
            KeyDeclaration(name: "DB_CONNECTION"),
            KeyDeclaration(name: "DB_URL"),
            KeyDeclaration(name: "APP_NAME"),
            KeyDeclaration(name: "APP_DESCRIPTION"),
            KeyDeclaration(name: "SSL_CERT"),
            KeyDeclaration(name: "API_ENDPOINT"),
        ]
        let keys = try await fetcher.fetch(declarations: declarations, keyMapping: [:])

        // Basic values
        XCTAssertEqual(keys[0].value, "localhost")
        XCTAssertEqual(keys[1].value, "5432")
        XCTAssertEqual(keys[2].value, "admin")

        // Quoted value
        XCTAssertEqual(keys[3].value, "super_secret_123")

        // Simple interpolation
        XCTAssertEqual(keys[4].value, "localhost:5432")

        // Complex interpolation with multiple variables
        XCTAssertEqual(keys[5].value, "postgres://admin:super_secret_123@localhost:5432/mydb")

        // Single-quoted value
        XCTAssertEqual(keys[6].value, "My Test App")

        // Double-quoted value
        XCTAssertEqual(keys[7].value, "A great app for testing")

        // Multi-line value
        let expectedCert = """

        -----BEGIN CERTIFICATE-----
        MIICpDCCAYwCCQDU+pQ4P2dG3DANBgkqhkiG9w0BAQsFADAUMRIw
        -----END CERTIFICATE-----

        """
        XCTAssertEqual(keys[8].value, expectedCert)

        // Nested interpolation (3 levels deep)
        XCTAssertEqual(keys[9].value, "https://example.com/api/v1")
    }

    // MARK: - Error Tests

    func test_throwsErrorForMissingFile() async {
        let fetcher = DotEnvFetcher(filePath: "/nonexistent/.env")
        let declarations = [KeyDeclaration(name: "API_KEY")]

        do {
            _ = try await fetcher.fetch(declarations: declarations, keyMapping: [:])
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is DotEnvFetcher.Error)
        }
    }

    func test_throwsErrorForMissingKey() async throws {
        let envContent = """
        OTHER_KEY=value
        """
        let envFile = try envContent.saveToTemporaryDirectory(filename: ".env")
        defer { try? FileManager.default.removeItem(at: envFile) }

        let fetcher = DotEnvFetcher(filePath: envFile.path)
        let declarations = [KeyDeclaration(name: "MISSING_KEY")]

        do {
            _ = try await fetcher.fetch(declarations: declarations, keyMapping: [:])
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is VariableFetchingError)
        }
    }

    static var allTests = [
        ("test_parsesSimpleKeyValuePairs", test_parsesSimpleKeyValuePairs),
        ("test_handlesQuotedValues", test_handlesQuotedValues),
        ("test_skipsCommentsAndEmptyLines", test_skipsCommentsAndEmptyLines),
        ("test_handlesValuesWithEqualsSign", test_handlesValuesWithEqualsSign),
        ("test_handlesKeyMapping", test_handlesKeyMapping),
        ("test_interpolatesVariableReferences", test_interpolatesVariableReferences),
        ("test_interpolatesMultipleVariablesInSameValue", test_interpolatesMultipleVariablesInSameValue),
        ("test_handlesNestedVariableReferences", test_handlesNestedVariableReferences),
        ("test_preservesUnresolvedVariables", test_preservesUnresolvedVariables),
        ("test_parsesMultilineValuesWithDoubleQuotes", test_parsesMultilineValuesWithDoubleQuotes),
        ("test_parsesMultilineValuesWithSingleQuotes", test_parsesMultilineValuesWithSingleQuotes),
        ("test_comprehensiveEnvFileParsing", test_comprehensiveEnvFileParsing),
        ("test_throwsErrorForMissingFile", test_throwsErrorForMissingFile),
        ("test_throwsErrorForMissingKey", test_throwsErrorForMissingKey),
    ]
}

// MARK: - Test Helpers

private extension String {
    func saveToTemporaryDirectory(filename: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename + "-" + UUID().uuidString)
        try write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
