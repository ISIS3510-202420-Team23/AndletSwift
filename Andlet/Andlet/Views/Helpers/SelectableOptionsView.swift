import SwiftUI

struct SelectableOptionsView: View {
    @Binding var selectedOption: String? // Estado ligado externamente para la opción seleccionada
    var options: [String] // Valores que se guardan en la base de datos o en el objeto observable
    var displayOptions: [String] // Valores que se muestran en la interfaz para el usuario
    var title: String // Título que se mostrará arriba de los botones
    var additionalText: String = "" // Texto adicional que puede aparecer al lado del primer botón
    var buttonWidth: CGFloat = 150 // Ancho fijo para los botones
    let primaryColor = Color(red: 12/255, green: 53/255, blue: 106/255)
    let secondaryColor = Color(red: 197/255, green: 221/255, blue: 255/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Título en la parte superior, ajustado para hacer salto de línea cuando sea necesario
            Text(title)
                .font(.custom("Montserrat-Light", size: 20))
                .foregroundColor(primaryColor)
                .fixedSize(horizontal: false, vertical: true) // Permite que el texto haga salto de línea
            
            // Botones de selección alineados a la izquierda y con tamaño fijo
            VStack(alignment: .leading, spacing: 10) {
                ForEach(options.indices, id: \.self) { index in
                    HStack {
                        // Botón
                        Button(action: {
                            selectedOption = options[index]
                        }) {
                            Text(displayOptions[index])
                                .foregroundColor(
                                    selectedOption == options[index]
                                    ? .white // Blanco si está seleccionado
                                    : primaryColor // Primario si no está seleccionado
                                )
                                .frame(width: buttonWidth, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(
                                            primaryColor,
                                            lineWidth: 2
                                        )
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(
                                                    selectedOption == options[index]
                                                    ? primaryColor
                                                    : secondaryColor
                                                )
                                        )
                                )
                        }

                        // Si hay texto adicional y es el primer botón, muéstralo
                        if index == 0 && !additionalText.isEmpty {
                            Text(additionalText)
                                .font(.custom("Montserrat-Light", size: 12))
                                .foregroundColor(primaryColor)
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

// Preview del componente con valores de ejemplo
struct SelectableOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SelectableOptionsView(
            selectedOption: .constant("a_room"),
            options: ["entire_place", "a_room"],
            displayOptions: ["An entire place", "A room"],
            title: "What type of place will guests have?"
        )
    }
}
