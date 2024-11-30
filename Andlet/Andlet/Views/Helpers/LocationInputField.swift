import SwiftUI

struct LocationInputField: View {
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

            ZStack(alignment: .leading) {
                // Cuadro de texto con ícono
                HStack {
                    // Ícono de ubicación dentro del cuadro de texto
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(primaryColor)
                        .padding(.leading, 10)
                    
                    TextField(placeholder, text: $text)
                        .padding(.vertical, 12) // Ajusta el padding del texto
                        .font(.custom("Montserrat-SemiBold", size: 12)) // Cambia la fuente del placeholder
                        .foregroundColor(primaryColor) // Color para el texto
                        .onChange(of: text) { oldValue, newValue in // Cambia a la sintaxis con dos parámetros
                            if newValue.count > maxCharacters {
                                text = String(newValue.prefix(maxCharacters))
                            }
                        }
                }
                .padding(.leading, 5) // Espacio para el ícono
                .padding(.trailing, 10)
                .frame(height: height)
                .background(Color.white)
                .cornerRadius(cornerRadius)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(primaryColor, lineWidth: 2))
            }
        }
    }
}
