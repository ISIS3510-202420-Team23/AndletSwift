import SwiftUI

struct IconInputField: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var maxCharacters: Int
    var height: CGFloat
    var cornerRadius: CGFloat
    var iconName: String // Ícono pasado por parámetro

    var body: some View {
        VStack(alignment: .leading) {
            // Título del campo
            Text(title)
                .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                .font(.custom("Montserrat-Light", size: 20))

            ZStack(alignment: .leading) {
                // Cuadro de texto con ícono personalizado
                HStack {
                    // Ícono pasado por parámetro
                    Image(systemName: iconName)
                        .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                        .padding(.leading, 10)

                    TextField(placeholder, text: $text)
                        .padding(.vertical, 12)
                        .font(.custom("Montserrat-SemiBold", size: 12))
                        .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                        .onChange(of: text) { newValue in
                            if newValue.count > maxCharacters {
                                text = String(newValue.prefix(maxCharacters))
                            }
                        }
                }
                .padding(.leading, 5)
                .padding(.trailing, 10)
                .frame(height: height)
                .background(Color.white)
                .cornerRadius(cornerRadius)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2))
            }
        } .padding(.bottom, 60)
    }
}
