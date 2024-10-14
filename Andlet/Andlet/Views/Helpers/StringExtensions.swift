import Foundation

extension String {
    // Verifica si el string contiene emojis
    var containsEmoji: Bool {
        return self.unicodeScalars.contains { $0.properties.isEmojiPresentation }
    }
}
