import SwiftUI

struct Step2View: View {
    @ObservedObject var propertyOfferData: PropertyOfferData // Usar PropertyOfferData para almacenar y compartir datos
    
    @State private var showWarning = false
    @State private var showWarningMessage = false // Estado para mostrar/ocultar el mensaje animado
    @State private var navigateToStep3 = false

    let maxPriceCharacters = 9

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(alignment: .leading) {
                    // Header para el formulario
                    HeaderView(step: "Step 2", title: "Tell us about your place")

                    VStack(alignment: .leading, spacing: 5) {
                        // Modificar SelectableOptionsView para trabajar con el tipo OfferType
                        SelectableOptionsView(
                            selectedOption: Binding<String?>(
                                get: { propertyOfferData.type.rawValue }, // Obtiene el valor como cadena
                                set: { newValue in
                                    if let newValue = newValue, let newType = OfferType(rawValue: newValue) {
                                        propertyOfferData.type = newType // Asigna el tipo completo solo si el nuevo valor es no-nulo
                                    }
                                }
                            ),
                            options: ["entire_place", "a_room"], // Valores que se guardarán en la base de datos
                            displayOptions: ["An entire place", "A room"], // Valores mostrados en la interfaz
                            title: "What type of place will guests have?"
                        )

                        Text("Let’s be more specific...")
                            .font(.custom("Montserrat-Light", size: 20))
                            .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                            .padding(.top, 5)

                        // Controles para seleccionar número de habitaciones, camas y baños
                        VStack(spacing: 15) {
                            IncrementDecrementView(title: "Rooms available for sublet", count: $propertyOfferData.numRooms)
                            IncrementDecrementView(title: "Beds", count: $propertyOfferData.numBeds)
                            IncrementDecrementView(title: "Bathrooms", count: $propertyOfferData.numBaths)
                        }
                        .padding(.bottom, 30)

                        // Campo para el precio por mes
                        PriceField(
                            title: "Now, set your price per month",
                            placeholder: "Enter price",
                            text: Binding(
                                get: { String(format: "%.0f", propertyOfferData.pricePerMonth) }, // Convierte Double a String
                                set: { newValue in
                                    if let value = Double(newValue) {
                                        propertyOfferData.pricePerMonth = value // Asigna el valor como Double
                                    } else {
                                        propertyOfferData.pricePerMonth = 0.0 // Valor por defecto si la conversión falla
                                    }
                                }
                            ),
                            maxCharacters: maxPriceCharacters,
                            height: 50,
                            cornerRadius: 10,
                            iconName: "dollarsign.circle"
                        )
                    }
                    .padding()

                    Spacer()

                    // Sección de navegación con textos (similar a ProfilePickerView)
                    HStack {
                        // Back link (Blanco con bordes azules y texto azul)
                        NavigationLink(destination: Step1View(propertyOfferData: propertyOfferData)
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

                        // Botón Next con validación antes de permitir la navegación
                        NavigationLink(destination: Step3View(propertyOfferData: propertyOfferData)
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
                                if propertyOfferData.type.rawValue.isEmpty || propertyOfferData.pricePerMonth <= 0.0 {
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

                                    // Imprimir el estado actual de propertyOfferData antes de continuar
                                    print("Step 2 - PropertyOfferData: \(propertyOfferData)")
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

// Reemplazar la función Preview para probar con el ObservableObject
#Preview {
    Step2View(propertyOfferData: PropertyOfferData())
}
