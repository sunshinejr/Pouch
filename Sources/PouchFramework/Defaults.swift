import Foundation

public enum Defaults {
    public static let input = Input.environmentVariable
}

public extension Defaults {
    enum Swift {
        public static let accessLevel = SwiftConfig.AccessLevel.internal
        public static let typeName = "Secrets"
        public static let isStatic = true
        public static let implementations = [String]()
        public static let encryption = Cipher.xor
        public static let representation = OutputRepresentation.variables
    }
}
