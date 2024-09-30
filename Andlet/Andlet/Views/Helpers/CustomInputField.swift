import SwiftUI

struct CustomInputField: View {
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
                .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                .font(.custom("Montserrat-Light", size: 20))

            ZStack(alignment: .topLeading) {
                // TextEditor para todos los inputs
                TextEditor(text: $text)
                    .padding()
                    .frame(height: height)
                    .background(Color.white)
                    .cornerRadius(cornerRadius)
                    .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2))
                    .onChange(of: text) { _, newValue in // Utiliza la nueva sintaxis con dos parámetros
                        if newValue.count > maxCharacters {
                            text = String(newValue.prefix(maxCharacters))
                        }
                    }

                // Placeholder simulado
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        .font(.custom("Montserrat-ExtraLightItalic", size: 12))
                        .allowsHitTesting(false) // Evita que el placeholder interfiera con la interacción del usuario
                }
            }

            // Contador de caracteres
            Text("\(text.count)/\(maxCharacters)")
                .font(.footnote)
                .foregroundColor(text.count > maxCharacters ? .red : Color(red: 12/255, green: 53/255, blue: 106/255))
                .padding(.bottom, 5)
        }
    }
}
