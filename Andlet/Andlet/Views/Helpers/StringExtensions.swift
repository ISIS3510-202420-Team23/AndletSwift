import Foundation

extension String {
    var isOnlyWhitespace: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var containsEmoji: Bool {
        return self.unicodeScalars.contains { $0.properties.isEmojiPresentation }
    }
    
    func removingExtraSpaces() -> String {
        // Reemplazar saltos de línea con un espacio, luego eliminar espacios adicionales
        return self.replacingOccurrences(of: "\n", with: " ")
                   .trimmingCharacters(in: .whitespacesAndNewlines)
                   .components(separatedBy: .whitespacesAndNewlines)
                   .filter { !$0.isEmpty }
                   .joined(separator: " ")
    }
}
