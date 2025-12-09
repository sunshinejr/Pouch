import Foundation

/// Fetches variables from a `.env` file.
public struct DotEnvFetcher {

    public enum Error: Swift.Error {
        case fileNotFound(path: String)
        case unableToReadFile(path: String)
        case unterminatedMultilineValue(key: String)
    }

    private let filePath: String

    /// Creates a new `DotEnvFetcher`.
    /// - Parameter filePath: Path to the `.env` file. Defaults to `.env` in the current directory.
    public init(filePath: String = ".env") {
        self.filePath = filePath
    }

    /// Fetches keys from the `.env` file.
    /// - Parameters:
    ///   - declarations: The key declarations to fetch.
    ///   - keyMapping: Optional mapping from declaration names to `.env` variable names.
    /// - Returns: An array of resolved keys.
    public func fetch(declarations: [KeyDeclaration], keyMapping: [String: String]) async throws -> [Key] {
        let environment = try parseEnvFile()
        var resolvedKeys = [Key]()

        for declaration in declarations {
            let mappedKey = keyMapping[declaration.name] ?? declaration.name
            guard let value = environment[mappedKey] else {
                throw VariableFetchingError.variableNotFound(name: declaration.name, input: .dotenv(filePath, keyMapping))
            }
            resolvedKeys.append(declaration.with(value: value))
        }

        return resolvedKeys
    }

    /// Parses the `.env` file and returns a dictionary of key-value pairs.
    private func parseEnvFile() throws -> [String: String] {
        let url = URL(fileURLWithPath: filePath)

        guard FileManager.default.fileExists(atPath: filePath) else {
            throw Error.fileNotFound(path: filePath)
        }

        guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
            throw Error.unableToReadFile(path: filePath)
        }

        var environment: [String: String] = [:]
        let lines = contents.components(separatedBy: "\n")
        var index = 0

        while index < lines.count {
            let line = lines[index]
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Skip empty lines and comments
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                index += 1
                continue
            }

            // Find the first equals sign
            guard let equalsIndex = trimmedLine.firstIndex(of: "=") else {
                index += 1
                continue
            }

            let key = String(trimmedLine[..<equalsIndex]).trimmingCharacters(in: .whitespaces)
            var value = String(trimmedLine[trimmedLine.index(after: equalsIndex)...])

            // Check for multi-line heredoc syntax (""" or ''')
            if value.hasPrefix("\"\"\"") || value.hasPrefix("'''") {
                let delimiter = String(value.prefix(3))
                var multilineValue = String(value.dropFirst(3))
                index += 1

                // Collect lines until we find the closing delimiter
                while index < lines.count {
                    let nextLine = lines[index]
                    if nextLine.contains(delimiter) {
                        // Found closing delimiter
                        if let delimiterIndex = nextLine.range(of: delimiter) {
                            multilineValue += "\n" + String(nextLine[..<delimiterIndex.lowerBound])
                        }
                        break
                    } else {
                        multilineValue += "\n" + nextLine
                        index += 1
                    }
                }

                if index >= lines.count && !lines[index - 1].contains(delimiter) {
                    throw Error.unterminatedMultilineValue(key: key)
                }

                value = multilineValue
            } else {
                value = value.trimmingCharacters(in: .whitespaces)

                // Remove surrounding quotes if present (single line)
                if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
                   (value.hasPrefix("'") && value.hasSuffix("'")) {
                    value = String(value.dropFirst().dropLast())
                }
            }

            if !key.isEmpty {
                environment[key] = value
            }

            index += 1
        }

        // Perform variable interpolation
        environment = interpolateVariables(in: environment)

        return environment
    }

    /// Interpolates variable references like `${VAR}` with their values.
    /// - Parameter environment: The parsed environment dictionary.
    /// - Returns: A new dictionary with interpolated values.
    private func interpolateVariables(in environment: [String: String]) -> [String: String] {
        var result = environment
        let pattern = "\\$\\{([^}]+)\\}"

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return environment
        }

        // Multiple passes to handle nested references
        for _ in 0..<10 {
            var changed = false

            for (key, value) in result {
                let range = NSRange(value.startIndex..., in: value)
                var newValue = value

                // Find all matches in reverse order to preserve indices
                let matches = regex.matches(in: value, range: range).reversed()

                for match in matches {
                    guard let varNameRange = Range(match.range(at: 1), in: value) else {
                        continue
                    }

                    let varName = String(value[varNameRange])

                    // Look up the variable in our environment first, then system environment
                    if let replacement = result[varName] ?? ProcessInfo.processInfo.environment[varName] {
                        guard let fullMatchRange = Range(match.range, in: newValue) else {
                            continue
                        }
                        newValue.replaceSubrange(fullMatchRange, with: replacement)
                        changed = true
                    }
                }

                result[key] = newValue
            }

            if !changed {
                break
            }
        }

        return result
    }
}
