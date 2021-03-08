import Foundation

extension Sequence {
    /// Beware! This isn't requiring the Hashable protocol for Element,
    /// and so finding unique element with this helper method is quite complex - O(n*n)
    func unique(identifying: (Element, Element) -> Bool) -> [Element] {
        var results = [Element]()
        for item in self where !results.contains(where: { identifying($0, item) }) {
            results.append(item)
        }
        return results
    }
}

extension Sequence where Element: Hashable {
    func unique() -> [Element] {
        return Array(Set(self))
    }
}
