import SwiftUI
import PhotosUI

struct Step1View: View {
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
    
    // Estado para controlar la navegación
    @State private var navigateToStep2 = false
    @State private var navigateBack = false
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading) {
                
                // Header para el formulario
                HeaderView(step: "Step 1", title: "List your place!")

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
                        iconName: "mappin.and.ellipse" // Ícono de ubicación
                    )
                }
                .padding()

                // Sección de botones con navegación al Step 2
                HStack {
                    CustomButton(title: "Back", action: {
                        navigateBack = true
                        presentationMode.wrappedValue.dismiss()
                    }, isPrimary: false)

                    Spacer()

                    NavigationLink(destination: Step2View(), isActive: $navigateToStep2) {
                        EmptyView()
                    }
                    .hidden()

                    CustomButton(title: "Next", action: {
                        navigateToStep2 = true
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
