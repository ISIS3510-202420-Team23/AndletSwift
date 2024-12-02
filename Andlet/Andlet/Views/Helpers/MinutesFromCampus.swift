import SwiftUI

struct MinutesFromCampusView: View {
    let primaryColor = Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255)
    @Binding var minutes: Int // Cambiado a Binding para recibir el valor desde Step3View
    @State var sliderValue: Double = 5 // Valor inicial predeterminado para el slider

    // Definición de colores reutilizables
    let sliderAccentColor = Color(hex: "0C356A")
    let backgroundColor = Color.white

    var body: some View {
        VStack {
            Text("How far is the property from campus?")
                .font(.custom("Montserrat-Light", size: 18))
                .foregroundColor(primaryColor)
                .padding(.bottom, 10)
                .fixedSize(horizontal: false, vertical: true) // Permitir saltos de línea si es necesario

            VStack(alignment: .leading) {
                // Slider optimizado
                Slider(value: $sliderValue, in: 5...30, step: 1)
                    .accentColor(sliderAccentColor)
                    .onChange(of: sliderValue) { newValue in
                        minutes = Int(newValue) // Actualizar `minutes` solo cuando el valor cambia
                    }
                    .onAppear {
                        sliderValue = Double(minutes) // Inicializar el slider con el valor actual de `minutes`
                    }

                HStack {
                    Spacer(minLength: 10) // Usar `minLength` para evitar repintados innecesarios
                    Text("\(minutes) mins")
                        .font(.custom("Montserrat-SemiBold", size: 14))
                        .foregroundColor(primaryColor) // Texto con color primario
                }
                .padding(.horizontal)
            }
            .padding()
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(primaryColor, lineWidth: 2) // Usar color primario para el borde
            )
        }
    }
}
