import Foundation

public final class OnePasswordFetcher {
    public enum Error: Swift.Error {
        case vaultNotFound(String)
        case sectionNotFound(String)
        case keysNotFound([String])
        case cliNotFound
        case cliError(String)
        case invalidResponse(String)
    }

    public let vault: String
    public let account: String?

    private var cache: [String: [String: Any]] = [:] // cache for keys, given we have the same vault, we can store

    public init(vault: String, account: String? = nil) throws {
        self.vault = vault
        self.account = account
        logger.log(.variableFetcher, "[1Password] initialized, fetching secrets...")
    }

    public func fetch(declarations: [KeyDeclaration], section: String, keyMapping: [String: String]) async throws -> [Key] {
        guard await isOnePasswordCLIAvailable() else {
            throw Error.cliNotFound
        }

        var fetchedKeys = [Key]()
        var missingKeys = [String]()

        for declaration in declarations {
            let mappedKey = keyMapping[declaration.name] ?? declaration.name

            do {
                let value = try await fetchKeyValueFromOnePassword(key: mappedKey, section: section)
                logger.log(.variableFetcher, "[1Password] Fetched value for key: \(mappedKey, color: .green)")
                fetchedKeys.append(Key(name: declaration.name, value: value))
            } catch let error as Error {
                missingKeys.append(declaration.name)
                switch error {
                case .vaultNotFound(let vault):
                    logger.log(.variableFetcher, "[1Password] Vault '\(vault)' not found for key: \(mappedKey, color: .red)")
                case .sectionNotFound(let section):
                    logger.log(.variableFetcher, "[1Password] Section '\(section)' not found for key: \(mappedKey, color: .red)")
                case .cliError(let message):
                    logger.log(.variableFetcher, "[1Password] CLI error for key \(mappedKey): \(message, color: .red)")
                case .invalidResponse(let message):
                    logger.log(.variableFetcher, "[1Password] Invalid response for key \(mappedKey): \(message, color: .red)")
                default:
                    logger.log(.variableFetcher, "[1Password] Error for key \(mappedKey): \(error, color: .red)")
                }
            } catch {
                missingKeys.append(declaration.name)
                logger.log(.variableFetcher, "[1Password] Unexpected error for key \(mappedKey): \(error, color: .red)")
            }
        }

        if !missingKeys.isEmpty {
            throw Error.keysNotFound(missingKeys)
        }

        return fetchedKeys
    }

    private func isOnePasswordCLIAvailable() async -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["op"]

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    private func fetchKeyValueFromOnePassword(key: String, section: String) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        var arguments = ["op", "item", "get", key, "--vault", vault, "--format", "json"]
        if let account = account {
            arguments += ["--account", account]
        }
        process.arguments = arguments

        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe

        do {
            let getJson: (String) throws -> [String: Any]? = { key in
                if let cached = self.cache[key] {
                    return cached
                }

                try process.run()
                process.waitUntilExit()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                if process.terminationStatus != 0 {
                    let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                    if errorOutput.contains("vault") && errorOutput.contains("not found") {
                        throw Error.vaultNotFound(self.vault)
                    }
                    throw Error.cliError(errorOutput)
                }

                guard let jsonString = String(data: data, encoding: .utf8),
                      let jsonData = jsonString.data(using: .utf8) else
                {
                    throw Error.invalidResponse("Failed to decode response")
                }

                return try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            }

            guard let item = try getJson(key), let fields = item["fields"] as? [[String: Any]] else {
                throw Error.invalidResponse("Invalid JSON structure")
            }

            cache[key] = item

            // Look for the field with the specified label (which is the "section")
            for field in fields {
                if let fieldLabel = field["label"] as? String,
                   fieldLabel == section,
                   let fieldValue = field["value"] as? String
                {
                    return fieldValue
                }
            }

            // If no section specified or section not found, try to get the first password field
            if section.isEmpty {
                for field in fields {
                    if let fieldType = field["type"] as? String,
                       fieldType == "CONCEALED",
                       let fieldValue = field["value"] as? String
                    {
                        return fieldValue
                    }
                }
            }

            // Collect available field labels for better error message
            let availableLabels = Set(fields.compactMap { field in
                if let fieldLabel = field["label"] as? String,
                   field["type"] as? String == "CONCEALED" {
                    return fieldLabel
                }
                return nil
            })
            
            let labelsMessage = availableLabels.isEmpty ? "no concealed fields found" : "available labels: \(availableLabels.sorted().joined(separator: ", "))"
            throw Error.sectionNotFound("\(section) (\(labelsMessage))")
        } catch let error as Error {
            throw error
        } catch {
            throw Error.cliError(error.localizedDescription)
        }
    }
}
