protocol FileContentsGenerating {
    associatedtype Config
    
    func generateFileContents(secrets: [Secret], config: Config) -> String
}
