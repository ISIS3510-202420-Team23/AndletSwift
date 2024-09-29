import SwiftUI

struct SelectableOptionsView: View {
    @Binding var selectedOption: String? // Estado ligado externamente para la opción seleccionada
    var options: [String] // Array de opciones para ser seleccionadas
    var title: String // Título que se mostrará arriba de los botones
    var additionalText: String = "" // Texto adicional que puede aparecer al lado del primer botón
    var buttonWidth: CGFloat = 150 // Ancho fijo para los botones

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Texto en la parte superior, ajustado para que haga salto de línea cuando sea necesario
            Text(title)
                .font(.custom("Montserrat-Light", size: 20))
                .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                .fixedSize(horizontal: false, vertical: true) // Permite que el texto haga salto de línea
            
            // Botones de selección alineados a la izquierda y con tamaño fijo
            VStack(alignment: .leading, spacing: 10) {
                ForEach(options.indices, id: \.self) { index in
                    HStack {
                        // Botón
                        Button(action: {
                            selectedOption = options[index] // Selecciona la opción correspondiente
                        }) {
                            Text(options[index])
                                .frame(width: buttonWidth, height: 40) // Tamaño fijo para los botones
                                .background(
                                    selectedOption == options[index]
                                    ? Color(red: 12/255, green: 53/255, blue: 106/255) // Fondo azul oscuro cuando está seleccionado
                                    : Color(red: 197/255, green: 221/255, blue: 255/255) // Fondo #C5DDFF cuando no está seleccionado
                                )
                                .foregroundColor(
                                    selectedOption == options[index]
                                    ? Color.white // Texto blanco cuando está seleccionado
                                    : Color(red: 12/255, green: 53/255, blue: 106/255) // Texto azul oscuro cuando no está seleccionado
                                )
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2) // Borde azul oscuro siempre
                                )
                        }

                        // Si hay texto adicional y es el primer botón, muéstralo
                        if index == 0 && !additionalText.isEmpty {
                            Text(additionalText)
                                .font(.custom("Montserrat-Light", size: 12))
                                .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                                .padding(.leading, 10) // Espaciado entre el botón y el texto
                                .fixedSize(horizontal: false, vertical: true) // Permite que el texto haga salto de línea
                        }
                    }
                }
            }
        }
        .padding(.bottom, 20) // Ajustar espacio inferior
    }
}

struct SelectableOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SelectableOptionsView(selectedOption: .constant(nil), options: ["Option 1", "Option 2"], title: "Select an Option")
    }
}
