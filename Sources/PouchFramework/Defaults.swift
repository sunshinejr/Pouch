public enum Defaults {
    public static let encryption = Cipher.xor
    public static let input = Input.environmentVariable
    public static let environmentCiKey = "CI"
}

public extension Defaults {
    enum Swift {
        public static let typeName = "Secrets"
    }
}
