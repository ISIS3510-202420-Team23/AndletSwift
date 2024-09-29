import SwiftUI

struct Step1View: View {
    @State private var placeTitle = ""
    @State private var placeDescription = ""
    @State private var placeAddress = ""
    @State private var selectedImage1: UIImage?
    @State private var selectedImage2: UIImage?
    @State private var showImagePicker1 = false
    @State private var showImagePicker2 = false
    @State private var showWarning = false
    @State private var navigateToStep2 = false // Control de navegación al siguiente paso
    @State private var showWarningMessage = false // Control para mostrar el mensaje de advertencia

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(alignment: .leading) {
                    // Header para el formulario
                    VStack(alignment: .leading, spacing: 5) {
                        HeaderView(step: "Step 1", title: "List your place!")
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)

                    // Campos de entrada
                    VStack(alignment: .leading, spacing: 10) {
                        CustomInputField(
                            title: "Give your place a short title",
                            placeholder: "Awesome title",
                            text: $placeTitle,
                            maxCharacters: 32,
                            height: 50,
                            cornerRadius: 8
                        )

                        CustomInputField(
                            title: "Create your description",
                            placeholder: "Awesome description",
                            text: $placeDescription,
                            maxCharacters: 500,
                            height: 100,
                            cornerRadius: 8
                        )

                        Text("Add some photos")
                            .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                            .font(.custom("Montserrat-Light", size: 20))

                        HStack {
                            Spacer()
                            HStack(spacing: 20) {
                                ImagePickerView(selectedImage: $selectedImage1, showImagePicker: $showImagePicker1)
                                ImagePickerView(selectedImage: $selectedImage2, showImagePicker: $showImagePicker2)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 5)

                        IconInputField(
                            title: "Where's your place located?",
                            placeholder: "Enter your address...",
                            text: $placeAddress,
                            maxCharacters: 48,
                            height: 50,
                            cornerRadius: 50,
                            iconName: "mappin.and.ellipse"
                        )
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Sección de navegación con textos (similar a ProfilePickerView)
                    HStack {
                        // Back link (Blanco con bordes azules y texto azul)
                        NavigationLink(destination: ProfilePickerView()
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
                        NavigationLink(destination: Step2View()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true),
                                       isActive: $navigateToStep2) {
                            EmptyView()
                        }
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white) // Texto blanco
                            .frame(width: 120, height: 50)
                            .background(Color(red: 12/255, green: 53/255, blue: 106/255)) // Fondo azul
                            .cornerRadius(15) // Esquinas menos redondeadas
                            .onTapGesture {
                                // Validación de campos y al menos una imagen seleccionada
                                if placeTitle.isEmpty || placeAddress.isEmpty || (selectedImage1 == nil && selectedImage2 == nil) {
                                    showWarning = true
                                    withAnimation {
                                        showWarningMessage = true
                                    }
                                    // Ocultar la advertencia después de 2 segundos
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            showWarningMessage = false
                                        }
                                    }
                                } else {
                                    showWarning = false
                                    navigateToStep2 = true // Permitir navegación a Step2
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                }
                .padding()

                // Mostrar mensaje de advertencia de forma sutil con animación
                if showWarningMessage {
                    VStack {
                        Spacer()
                            .frame(height: 10) // Espacio arriba para que el mensaje quede más abajo

                        Text("Please fill out all required fields and add at least one photo before proceeding")
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
            .navigationBarHidden(true) // Ocultar la barra de navegación para esta vista
        }
    }
}


#Preview {
    Step1View()
}
