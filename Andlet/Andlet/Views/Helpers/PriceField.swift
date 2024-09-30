import SwiftUI

struct PriceField: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var maxCharacters: Int
    var height: CGFloat
    var cornerRadius: CGFloat
    var iconName: String // Ícono pasado por parámetro

    @State private var formattedText: String = ""

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

                    TextField(placeholder, text: $formattedText)
                        .padding(.vertical, 12)
                        .font(.custom("Montserrat-SemiBold", size: 12))
                        .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                        .keyboardType(.numberPad) // Configuración para solo aceptar números
                        .onChange(of: formattedText) { oldValue, newValue in
                            // Filtrar solo números y limitar el número de caracteres a maxCharacters
                            let filteredValue = newValue.filter { $0.isNumber }
                            if filteredValue.count > maxCharacters {
                                formattedText = formatNumber(String(filteredValue.prefix(maxCharacters)))
                            } else {
                                formattedText = formatNumber(filteredValue)
                            }

                            // Actualizar el valor original del binding con el número sin formato
                            if let numberValue = Int(filteredValue) {
                                text = String(numberValue)
                            } else {
                                text = "0"
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
        .onAppear {
            // Inicializar el texto formateado con el valor actual
            formattedText = formatNumber(text)
        }
    }

    // Función para formatear el número con puntos de mil
    private func formatNumber(_ value: String) -> String {
        // Convertir el valor a número entero
        guard let number = Int(value) else { return value }
        
        // Aplicar formato con separador de miles
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."

        // Retornar el número formateado o el valor original si la conversión falla
        return numberFormatter.string(from: NSNumber(value: number)) ?? value
    }
}
