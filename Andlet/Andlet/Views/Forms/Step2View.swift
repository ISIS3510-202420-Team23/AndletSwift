import SwiftUI

struct Step2View: View {
    // Variables de estado para controlar el contenido y la navegación
    @State private var rooms = 1
    @State private var beds = 1
    @State private var bathrooms = 1
    @State private var pricePerMonth = ""
    @State private var selectedOption: String? = nil // Opción seleccionada en SelectableOptionsView
    @State private var showWarning = false
    @State private var showWarningMessage = false // Estado para mostrar/ocultar el mensaje animado
    @State private var navigateToStep3 = false

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
                            selectedOption: $selectedOption, // Bindear la opción seleccionada
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
                        
                        PriceField(
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

                        // Botón Next con validación antes de permitir la navegación
                        NavigationLink(destination: Step3View()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true),
                                       isActive: $navigateToStep3) {
                            EmptyView()
                        }
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white) // Texto blanco
                            .frame(width: 120, height: 50)
                            .background(Color(red: 12/255, green: 53/255, blue: 106/255)) // Fondo azul
                            .cornerRadius(15) // Esquinas menos redondeadas
                            .onTapGesture {
                                // Validación de selección y precio
                                if selectedOption == nil || pricePerMonth.isEmpty {
                                    showWarning = true
                                    showWarningMessage = true // Mostrar advertencia sutil

                                    // Ocultar la advertencia después de 2 segundos
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            showWarningMessage = false
                                        }
                                    }
                                } else {
                                    showWarning = false
                                    navigateToStep3 = true // Permitir navegación a Step3
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

                        Text("Please fill out all required fields before proceeding")
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
    Step2View()
}
