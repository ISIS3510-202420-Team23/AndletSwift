import SwiftUI

struct PriceField: View {
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
                        .keyboardType(.numberPad) // Configuración para solo aceptar números
                        .onChange(of: text) { newValue in
                            let filteredValue = newValue.filter { $0.isNumber }
                            if filteredValue.count > maxCharacters {
                                text = String(filteredValue.prefix(maxCharacters))
                            } else {
                                text = formatNumber(filteredValue)
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
        }
        .padding(.bottom, 60)
    }

    // Función para formatear el número con puntos de mil
    private func formatNumber(_ value: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let number = Int(value) ?? 0
        return numberFormatter.string(from: NSNumber(value: number)) ?? value
    }
}
