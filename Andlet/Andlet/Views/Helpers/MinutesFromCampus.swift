import SwiftUI

struct MinutesFromCampusView: View {
    @State private var minMinutes: Double = 0
    @State private var maxMinutes: Double = 30

    var body: some View {
        VStack {
            // Texto superior centrado
            Text("How far is the property from campus?")
                .font(.custom("Montserrat-Light", size: 18))
                .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                .padding(.bottom, 10)
                .fixedSize(horizontal: false, vertical: true) // Permite que el texto haga salto de línea
            
            VStack (alignment: .leading){
                
                Slider(value: $maxMinutes, in: 0...30, step: 1)
                    .accentColor(Color(hex: "0C356A"))
                HStack {
                    Spacer()
                    Text("\(Int(maxMinutes)) mins")
                }
                .padding(.horizontal)
                
            }
            .padding()
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2) // Borde azul
            )
            Spacer ()
        }
    }
}
