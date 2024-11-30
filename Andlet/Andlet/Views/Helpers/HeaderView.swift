import SwiftUI

struct HeaderView: View {
    let primaryColor = Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255)
    var step: String
    var title: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(step)
                .font(.custom("LeagueSpartan-Medium", size: 25))
                .foregroundColor(primaryColor)
                .padding(.bottom, 2)

            // Título con las palabras ajustándose en una nueva línea si no caben completas
            Text(attributedTitle(for: title))
                .font(.custom("LeagueSpartan-ExtraBold", size: 35))
                .lineLimit(nil) // Permitir múltiples líneas
                .fixedSize(horizontal: false, vertical: true) // Ajuste de líneas completo
                .multilineTextAlignment(.leading) // Alineación a la izquierda
        }
        .padding(.leading, 16) // Agrega padding a la izquierda
        .padding(.bottom, 5)
    }
    
    // Función para crear un AttributedString con las palabras resaltadas
    func attributedTitle(for title: String) -> AttributedString {
        var attributedString = AttributedString(title)
        let highlightedWords: [String] = ["List", "about", "preferences"]
        let defaultColor = primaryColor
        
        // Aplicar color predeterminado (azul) a todo el texto
        attributedString.foregroundColor = defaultColor
        
        // Resaltar palabras específicas en amarillo
        for word in highlightedWords {
            if let range = attributedString.range(of: word) {
                attributedString[range].foregroundColor = Color(red: 255/255, green: 185/255, blue: 0/255) // Amarillo
            }
        }
        
        return attributedString
    }
}
