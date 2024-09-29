import SwiftUI
import PhotosUI

struct Step1View: View {
    @ObservedObject var navigationState: NavigationState

    @State private var placeTitle = ""
    @State private var placeDescription = ""
    @State private var placeAddress = ""
    @State private var selectedImage1: UIImage?
    @State private var selectedImage2: UIImage?
    @State private var showImagePicker1 = false
    @State private var showImagePicker2 = false

    let maxTitleCharacters = 32
    let maxAddressCharacters = 48
    let maxDescriptionCharacters = 500

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                VStack(alignment: .leading, spacing: 5) {
                    HeaderView(step: "Step 1", title: "List your place!")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 10) {
                    CustomInputField(
                        title: "Give your place a short title",
                        placeholder: "Awesome title",
                        text: $placeTitle,
                        maxCharacters: maxTitleCharacters,
                        height: 50,
                        cornerRadius: 8
                    )

                    CustomInputField(
                        title: "Create your description",
                        placeholder: "Awesome description",
                        text: $placeDescription,
                        maxCharacters: maxDescriptionCharacters,
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
                        maxCharacters: maxAddressCharacters,
                        height: 50,
                        cornerRadius: 50,
                        iconName: "mappin.and.ellipse"
                    )
                }
                .padding(.horizontal)

                Spacer()

                VStack {
                    HStack {
                        CustomButton(title: "Back", action: {
                            withAnimation(.easeInOut) {
                                navigationState.currentStep = .profilePicker
                            }
                        }, isPrimary: false)

                        Spacer()

                        CustomButton(title: "Next", action: {
                            withAnimation(.easeInOut) {
                                navigationState.currentStep = .step2
                            }
                        }, isPrimary: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(true) // Asegura que la barra de navegación esté oculta
        .onAppear {
            // Reiniciar las propiedades de layout para asegurar que la vista se muestre correctamente
            placeTitle = ""
            placeDescription = ""
            placeAddress = ""
        }
    }
}
