import SwiftUI

struct Step1View: View {
    @ObservedObject var propertyOfferData: PropertyOfferData
    @StateObject private var viewModel = PropertyViewModel()

    @State private var showImagePicker1 = false
    @State private var showImagePicker2 = false
    @State private var showWarningMessage = false
    @State private var warningMessageText = ""
    @State private var navigateToStep2 = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 5) {
                        HeaderView(step: "Step 1", title: "List your place!")
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        CustomInputField(
                            title: "Give your place a short title",
                            placeholder: "Awesome title",
                            text: $propertyOfferData.placeTitle,
                            maxCharacters: 32,
                            height: 60,
                            cornerRadius: 8
                        )

                        CustomInputField(
                            title: "Create your description",
                            placeholder: "Awesome description",
                            text: $propertyOfferData.placeDescription,
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
                                // ImagePicker for first image
                                ImagePickerView(
                                    selectedImage: Binding<UIImage?>(
                                        get: {
                                            if let data = propertyOfferData.selectedImagesData.first {
                                                return UIImage(data: data)
                                            }
                                            return nil
                                        },
                                        set: { newImage in
                                            if let newImage = newImage, let data = newImage.jpegData(compressionQuality: 0.8) {
                                                propertyOfferData.saveImage(data: data, for: "imagen1")
                                                if propertyOfferData.selectedImagesData.isEmpty {
                                                    propertyOfferData.selectedImagesData.append(data)
                                                } else {
                                                    propertyOfferData.selectedImagesData[0] = data
                                                }
                                            }
                                        }
                                    ),
                                    showImagePicker: $showImagePicker1
                                )

                                // ImagePicker for second image
                                ImagePickerView(
                                    selectedImage: Binding<UIImage?>(
                                        get: {
                                            if propertyOfferData.selectedImagesData.count > 1 {
                                                return UIImage(data: propertyOfferData.selectedImagesData[1])
                                            }
                                            return nil
                                        },
                                        set: { newImage in
                                            if let newImage = newImage, let data = newImage.jpegData(compressionQuality: 0.8) {
                                                propertyOfferData.saveImage(data: data, for: "imagen2")
                                                if propertyOfferData.selectedImagesData.count > 1 {
                                                    propertyOfferData.selectedImagesData[1] = data
                                                } else {
                                                    propertyOfferData.selectedImagesData.append(data)
                                                }
                                            } else {
                                                // Remove the second image if not selected
                                                if propertyOfferData.selectedImagesData.count > 1 {
                                                    propertyOfferData.selectedImagesData.remove(at: 1)
                                                }
                                            }
                                        }
                                    ),
                                    showImagePicker: $showImagePicker2
                                )
                            }
                            Spacer()
                        }
                        .padding(.bottom, 5)

                        IconInputField(
                            title: "Where's your place located?",
                            placeholder: "Enter your address...",
                            text: $propertyOfferData.placeAddress,
                            maxCharacters: 48,
                            height: 50,
                            cornerRadius: 50,
                            iconName: "mappin.and.ellipse"
                        )
                    }
                    .padding(.horizontal)

                    Spacer()

                    HStack {
                        NavigationLink(destination: MainTabLandlordView()
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

                        if #available(iOS 16.0, *) {
                            NavigationLink(
                                value: navigateToStep2,
                                label: { EmptyView() }
                            )
                            .navigationDestination(isPresented: $navigateToStep2) {
                                Step2View(propertyOfferData: propertyOfferData)
                                    .navigationBarBackButtonHidden(true)
                                    .navigationBarHidden(true)
                            }
                        } else {
                            NavigationLink(destination: Step2View(propertyOfferData: propertyOfferData)
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true),
                                           isActive: $navigateToStep2) {
                                EmptyView()
                            }
                        }

                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color(red: 12/255, green: 53/255, blue: 106/255))
                            .cornerRadius(15)
                            .onTapGesture {
                                // Validate required fields
                                if propertyOfferData.placeTitle.isOnlyWhitespace || propertyOfferData.placeAddress.isOnlyWhitespace {
                                    warningMessageText = "Please do not use only spaces in the title or address fields."
                                    showWarningMessage = true
                                } else if !propertyOfferData.placeDescription.isEmpty && propertyOfferData.placeDescription.isOnlyWhitespace {
                                    warningMessageText = "Description cannot contain only spaces."
                                    showWarningMessage = true
                                } else if propertyOfferData.placeTitle.isEmpty || propertyOfferData.placeAddress.isEmpty || propertyOfferData.selectedImagesData.isEmpty {
                                    warningMessageText = "Please fill in all the required fields and add at least one photo."
                                    showWarningMessage = true
                                } else if propertyOfferData.placeTitle.containsEmoji || propertyOfferData.placeAddress.containsEmoji || propertyOfferData.placeDescription.containsEmoji {
                                    warningMessageText = "Please remove any emojis from the text fields."
                                    showWarningMessage = true
                                } else {
                                    propertyOfferData.placeTitle = propertyOfferData.placeTitle.removingExtraSpaces()
                                    propertyOfferData.placeDescription = propertyOfferData.placeDescription.removingExtraSpaces()
                                    propertyOfferData.placeAddress = propertyOfferData.placeAddress.removingExtraSpaces()

                                    // Clear second image if not selected
                                    if propertyOfferData.selectedImagesData.count > 1 && propertyOfferData.selectedImagesData[1] == nil {
                                        propertyOfferData.selectedImagesData.remove(at: 1)
                                    }

                                    showWarningMessage = false
                                    viewModel.assignAuthenticatedUser(to: propertyOfferData)
                                    navigateToStep2 = true
                                }

                                // Hide warning message after 2 seconds
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
                    .padding(.top, 40)
                }
                .padding()

                if showWarningMessage {
                    VStack {
                        Spacer()
                            .frame(height: 10)
                        Text(warningMessageText)
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .transition(.move(edge: .top))
                            .animation(.easeInOut(duration: 0.5), value: showWarningMessage)
                            .offset(y: showWarningMessage ? 0 : -100)
                            .zIndex(1)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
        }
        .onAppear {
            viewModel.assignAuthenticatedUser(to: propertyOfferData)
        }
    }
}
