enum VariableFetchingError: Error {
    case variableNotFound(name: String, input: Input)
}
