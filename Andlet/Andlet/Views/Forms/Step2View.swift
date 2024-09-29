import SwiftUI

struct Step2View: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToStep3 = false
    @State private var rooms = 0
    @State private var beds = 0
    @State private var bathrooms = 0
    @State private var pricePerMonth = ""

    let maxPriceCharacters = 20

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading) {
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    // Header para el formulario
                    HeaderView(step: "Step 2", title: "Tell us about your place")
                    
                } .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 5) {
                    // Componente de selección reutilizable ajustado
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

                    // Campo para ingresar el precio por mes
                    IconInputField(
                        title: "Now, set your price per month",
                        placeholder: "Enter price",
                        text: $pricePerMonth,
                        maxCharacters: maxPriceCharacters,
                        height: 50,
                        cornerRadius: 10,
                        iconName: "dollarsign.circle" // Ícono de precio
                    )
                }
                .padding(.bottom, 10)
                .padding(.horizontal) // Padding general para todo el bloque

                // Sección de botones con navegación al Step 3
                HStack {
                    CustomButton(title: "Back", action: {
                        presentationMode.wrappedValue.dismiss()
                    }, isPrimary: false)

                    Spacer()

                    NavigationLink(destination: Step3View(), isActive: $navigateToStep3) {
                        EmptyView()
                    }
                    .hidden()

                    CustomButton(title: "Next", action: {
                        navigateToStep3 = true
                    }, isPrimary: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}
