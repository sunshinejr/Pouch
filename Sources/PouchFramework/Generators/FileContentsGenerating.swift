protocol FileContentsGenerating {
    associatedtype LanguageConfig
    
    func generateFileContents(secrets: [Secret], config: LanguageConfig) -> String
}

protocol SwiftFileContentsGenerating: FileContentsGenerating where LanguageConfig == SwiftConfig {}
