import Foundation

extension String {
    func uppercaseFirstLetter() -> String {
        guard isNotEmpty else { return self }
        
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
    
    func toCamelCase() -> String {
        let parts = components(separatedBy: CharacterSet.alphanumerics.inverted)
        
        guard let firstPart = parts.first?.lowercased() else { return self }
        
        let otherParts = Array(parts.dropFirst().map { $0.uppercaseFirstLetter() })
        
        return [[firstPart], otherParts].flatMap { $0 }.joined(separator: "")
    }
}
