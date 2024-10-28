import Foundation

extension String {
    var isOnlyWhitespace: Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var containsEmoji: Bool {
        return self.unicodeScalars.contains { $0.properties.isEmojiPresentation }
    }
    
    func removingExtraSpaces() -> String {
        return self.trimmingCharacters(in: .whitespaces)
                   .components(separatedBy: .whitespaces)
                   .filter { !$0.isEmpty }
                   .joined(separator: " ")
    }
}
