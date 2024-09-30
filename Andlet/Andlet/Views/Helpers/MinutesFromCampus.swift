import SwiftUI

// MinutesFromCampusView modificado para aceptar un Binding<Int> y configurar el valor mínimo en 5
struct MinutesFromCampusView: View {
    @Binding var minutes: Int // Cambiado a Binding para recibir el valor desde Step3View

    var body: some View {
        VStack {
            Text("How far is the property from campus?")
                .font(.custom("Montserrat-Light", size: 18))
                .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                .padding(.bottom, 10)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading) {
                // Cambiar el rango del slider para que empiece desde 5
                Slider(value: Binding<Double>(
                    get: { Double(minutes) },
                    set: { newValue in
                        minutes = Int(newValue)
                    }
                ), in: 5...30, step: 1) // El valor mínimo ahora es 5
                .accentColor(Color(hex: "0C356A"))

                HStack {
                    Spacer()
                    Text("\(minutes) mins")
                }
                .padding(.horizontal)
            }
            .padding()
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2)
            )
            Spacer()
        }
    }
}
