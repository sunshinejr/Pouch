public enum Input: String, Codable, Equatable {
    case environmentVariable = "env"
    /// Overrides in Retrieve command to env when CI=true.
    case environmentOrStandardInput = "env-or-stdin"
}
