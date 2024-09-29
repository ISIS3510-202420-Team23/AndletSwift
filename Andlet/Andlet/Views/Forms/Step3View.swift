import SwiftUI

struct Step3View: View {
    // Variables de estado para controlar el contenido y la navegación
    @State private var rooms = 0
    @State private var beds = 0
    @State private var bathrooms = 0
    @State private var pricePerMonth = ""
    @State private var startDate = Date()
    @State private var endDate = Date()

    let maxPriceCharacters = 20

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    // Header para el formulario
                    HeaderView(step: "Step 3", title: "Set up your preferences")
                    
                    VStack(alignment: .leading, spacing: 5) {
                        SelectableOptionsView(
                            options: ["Restrict to Andes", "Any Andlet guest"],
                            title: "Choose who will be your guest",
                            additionalText: "Only users signed in with a @uniandes.edu.co email will be able to contact you"
                        )
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal)

                    // Componente de selección de rango de fechas
                    DateRangePickerView(startDate: $startDate, endDate: $endDate)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)

                    MinutesFromCampusView()
                        .padding(.bottom, 50)

                    // Texto de finalización
                    Text("Perfect! You’re all set.\nFinish up\nand publish :)")
                        .font(.custom("Montserrat-Regular", size: 20))
                        .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                        .multilineTextAlignment(.leading)
                        .padding(.top, 30)
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                    
                    // Botones de navegación con NavigationLink
                    HStack {
                        // Back link (Blanco con bordes azules y texto azul)
                        NavigationLink(destination: Step2View()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)) {
                                Text("Back")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255)) // Azul del Step
                                    .frame(width: 120, height: 50)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2)
                                    )
                                    .cornerRadius(15) // Esquinas menos redondeadas
                        }

                        Spacer()

                        // Next link (Fondo azul con texto negro)
                        NavigationLink(destination: MainTabLandlordView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)) {
                                Text("Save")
                                    .font(.headline)
                                    .foregroundColor(.white) // Texto en negro
                                    .frame(width: 120, height: 50)
                                    .background(Color(red: 12/255, green: 53/255, blue: 106/255)) // Fondo azul
                                    .cornerRadius(15) // Esquinas menos redondeadas
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    Step3View()
}
