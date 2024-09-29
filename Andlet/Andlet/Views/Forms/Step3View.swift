import SwiftUI

struct Step3View: View {
    @State private var rooms = 0
    @State private var beds = 0
    @State private var bathrooms = 0
    @State private var pricePerMonth = ""
    @State private var startDate = Date() // Fecha inicial es la actual
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date() // Fecha final es 1 semana después
    @State private var showWarningMessage = false
    @State private var navigateToMainTab = false // Estado para la navegación
    @State private var selectedOption: String? = nil // Opción seleccionada en SelectableOptionsView

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    // Header para el formulario
                    HeaderView(step: "Step 3", title: "Set up your preferences")
                    
                    VStack(alignment: .leading, spacing: 5) {
                        // Agregar SelectableOptionsView
                        SelectableOptionsView(
                            selectedOption: $selectedOption,
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
                                    .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                                    .frame(width: 120, height: 50)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2)
                                    )
                                    .cornerRadius(15)
                        }

                        Spacer()

                        // Next link (Fondo azul con texto negro)
                        NavigationLink(destination: MainTabLandlordView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true),
                                       isActive: $navigateToMainTab) {
                            EmptyView()
                        }
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color(red: 12/255, green: 53/255, blue: 106/255))
                            .cornerRadius(15)
                            .onTapGesture {
                                // Validación simplificada de fechas y opción seleccionada
                                let todayStartOfDay = Calendar.current.startOfDay(for: Date()) // Día de hoy a las 00:00
                                
                                if startDate < todayStartOfDay || endDate <= startDate || selectedOption == nil {
                                    showWarningMessage = true
                                } else {
                                    showWarningMessage = false
                                    navigateToMainTab = true
                                }

                                // Mostrar el mensaje de advertencia por 2 segundos si hay algún error
                                if showWarningMessage {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            showWarningMessage = false
                                        }
                                    }
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .padding()
                
                // Mostrar mensaje de advertencia de forma sutil con animación
                if showWarningMessage {
                    VStack {
                        Spacer()
                            .frame(height: 10) // Espacio arriba para que el mensaje quede más abajo

                        Text("Please select a valid date range and an option and/or fill all the requested fields")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .transition(.move(edge: .top)) // Efecto de deslizamiento
                            .animation(.easeInOut(duration: 0.5), value: showWarningMessage) // Controla la animación con valor
                            .offset(y: showWarningMessage ? 0 : -100) // Desliza desde arriba
                            .zIndex(1) // Asegura que el mensaje esté encima del contenido
                    }
                    .padding(.top, 10) // Ajusta la posición del mensaje
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    Step3View()
}
