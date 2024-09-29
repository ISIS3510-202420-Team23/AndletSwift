import SwiftUI

struct Step2View: View {
    // Variables de estado para controlar el contenido y la navegación
    @State private var rooms = 1
    @State private var beds = 1
    @State private var bathrooms = 1
    @State private var pricePerMonth = ""
    
    let maxPriceCharacters = 20

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    // Header para el formulario
                    HeaderView(step: "Step 2", title: "Tell us about your place")
                    
                    VStack(alignment: .leading, spacing: 5) {
                        SelectableOptionsView(
                            options: ["An entire place", "A room"],
                            title: "What type of place will guests have?"
                        )
                        
                        Text("Let’s be more specific...")
                            .font(.custom("Montserrat-Light", size: 20))
                            .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                            .padding(.top, 5)
                        
                        VStack(spacing: 15) {
                            IncrementDecrementView(title: "Rooms available for sublet", count: $rooms)
                            IncrementDecrementView(title: "Beds", count: $beds)
                            IncrementDecrementView(title: "Bathrooms", count: $bathrooms)
                        }
                        .padding(.bottom, 30)
                        
                        IconInputField(
                            title: "Now, set your price per month",
                            placeholder: "Enter price",
                            text: $pricePerMonth,
                            maxCharacters: maxPriceCharacters,
                            height: 50,
                            cornerRadius: 10,
                            iconName: "dollarsign.circle"
                        )
                    }
                    .padding()
                    
                    Spacer()
                    
                    HStack {
                        // Back link (Blanco con bordes azules y texto azul)
                        NavigationLink(destination: Step1View()
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
                        NavigationLink(destination: Step3View()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)) {
                                Text("Next")
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
    Step2View()
}
