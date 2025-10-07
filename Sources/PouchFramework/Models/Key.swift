public struct Key {
    public let name: String
    public let value: String
    public let generatedName: String?
    
    public init(name: String, value: String, generatedName: String? = nil) {
        self.name = name
        self.value = value
        self.generatedName = generatedName
    }
}
