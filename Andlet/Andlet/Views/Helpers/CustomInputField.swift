import SwiftUI

struct CustomInputField: View {
    let primaryColor = Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255)
    var title: String
    var placeholder: String
    @Binding var text: String
    var maxCharacters: Int
    var height: CGFloat // Ajusta el tamaño del cuadro de texto
    var cornerRadius: CGFloat // Ajusta qué tan redondeados son los bordes

    var body: some View {
        VStack(alignment: .leading) {
            // Título del campo
            Text(title)
                .foregroundColor(primaryColor)
                .font(.custom("Montserrat-Light", size: 20))

            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .padding()
                    .frame(height: height)
                    .cornerRadius(cornerRadius) // Combina el fondo y el borde
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(primaryColor, lineWidth: 2)
                    )
                    .onChange(of: text) { _, newValue in
                        if newValue.count > maxCharacters {
                            text = String(newValue.prefix(maxCharacters))
                        }
                    }

                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(primaryColor)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        .font(.custom("Montserrat-ExtraLightItalic", size: 12))
                }
            }

            // Contador de caracteres
            Text("\(text.count)/\(maxCharacters)")
                .font(.footnote)
                .foregroundColor(text.count > maxCharacters ? .red : primaryColor)
                .padding(.bottom, 5)
        }
    }
}
