import SwiftUI

struct Step3View: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateSave = false
    @State private var rooms = 0
    @State private var beds = 0
    @State private var bathrooms = 0
    @State private var pricePerMonth = ""
    
    // Fechas para el rango
    @State private var startDate = Date()
    @State private var endDate = Date()

    let maxPriceCharacters = 20

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading) {
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    // Header para el formulario
                    HeaderView(step: "Step 3", title: "Set up your preferences")
                    
                } .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 5) {
                    // Componente de selección reutilizable ajustado
                    SelectableOptionsView(
                        options: ["Restrict to Andes", "Any Andlet guest"],
                        title: "Choose who will be your guest",
                        additionalText: "Only users signed in with a @uniandes.edu.co email will be able to contact you"
                    )

                }
                .padding(.bottom, 20)
                .padding(.horizontal) // Padding general para todo el bloque
                
                // Componente de selección de rango de fechas
                DateRangePickerView(startDate: $startDate, endDate: $endDate)
                    .frame(maxWidth: .infinity) // Centramos el contenido
                    .padding(.bottom, 150)

                // Agregar texto final alineado a la izquierda y con color azul, justo antes de los botones
                Text("Perfect! You’re all set.\nFinish up\nand publish :)")
                    .font(.custom("Montserrat-Regular", size: 20))
                    .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255)) // Color azul
                    .multilineTextAlignment(.leading) // Alineación a la izquierda
                    .padding(.top, 30) // Padding superior para separar el texto
                    .padding(.leading, 20) // Padding izquierdo para alinearlo con el resto
                    .frame(maxWidth: .infinity, alignment: .leading) // Asegurar que esté alineado a la izquierda
                
                // Sección de botones con navegación al Step 1
                HStack {
                    
                    

                    CustomButton(title: "Back", action: {
                        presentationMode.wrappedValue.dismiss()
                    }, isPrimary: false)

                    Spacer()

                    NavigationLink(destination: HomepageRentView(), isActive: $navigateSave) {
                        EmptyView()
                    }
                    .hidden()

                    CustomButton(title: "Save", action: {
                        navigateSave = true
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
