import SwiftUI

struct Step3View: View {
    @ObservedObject var propertyOfferData: PropertyOfferData
    @StateObject private var viewModel = PropertyViewModel() // Instancia del ViewModel como @StateObject

    @State private var showWarningMessage = false
    @State private var navigateToMainTab = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(alignment: .leading) {
                    HeaderView(step: "Step 3", title: "Set up your preferences")

                    VStack(alignment: .leading, spacing: 5) {
                        SelectableOptionsView(
                            selectedOption: Binding<String?>(
                                get: { propertyOfferData.onlyAndes ? "true" : "false" },
                                set: { newValue in
                                    if let value = newValue {
                                        propertyOfferData.onlyAndes = (value == "true")
                                    }
                                }
                            ),
                            options: ["true", "false"],
                            displayOptions: ["Restrict to Andes", "Any Andlet guest"],
                            title: "Choose who will be your guest",
                            additionalText: "Only users signed in with a @uniandes.edu.co email will be able to contact you"
                        )
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal)

                    DateRangePickerView(startDate: $propertyOfferData.initialDate, endDate: $propertyOfferData.finalDate)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)

                    MinutesFromCampusView(minutes: Binding<Int>(
                        get: { propertyOfferData.minutesFromCampus },
                        set: { newValue in
                            propertyOfferData.minutesFromCampus = max(newValue, 5)
                        }
                    ))
                    .padding(.bottom, 50)

                    Text("Perfect! You’re all set.\nFinish up\nand publish :)")
                        .font(.custom("Montserrat-Regular", size: 20))
                        .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                        .multilineTextAlignment(.leading)
                        .padding(.top, 30)
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    HStack {
                        NavigationLink(destination: Step2View(propertyOfferData: propertyOfferData)
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
                                value: navigateToMainTab,
                                label: { EmptyView() }
                            )
                            .navigationDestination(isPresented: $navigateToMainTab) {
                                MainTabLandlordView()
                                    .navigationBarBackButtonHidden(true)
                                    .navigationBarHidden(true)
                            }
                        } else {
                            NavigationLink(destination: MainTabLandlordView()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true),
                                           isActive: $navigateToMainTab) {
                                EmptyView()
                            }
                        }

                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color(red: 12/255, green: 53/255, blue: 106/255))
                            .cornerRadius(15)
                            .onTapGesture {
                                let todayStartOfDay = Calendar.current.startOfDay(for: Date())

                                if propertyOfferData.initialDate >= todayStartOfDay && propertyOfferData.finalDate > propertyOfferData.initialDate {
                                    showWarningMessage = false

                                    viewModel.getNextPropertyID { propertyID in
                                        guard let propertyID = propertyID else {
                                            print("Error: No se pudo obtener el siguiente ID de propiedad")
                                            return
                                        }

                                        propertyOfferData.propertyID = propertyID
                                        print("Next Property ID: \(propertyID)")

                                        let photoNames = propertyOfferData.selectedImagesData.enumerated().map { (index, _) in
                                            return "\(propertyOfferData.userId)_\(propertyOfferData.propertyID)_\(index + 1).jpg"
                                        }
                                        propertyOfferData.photos = photoNames
                                        print("Nombres de las fotos determinados: \(photoNames)")

                                        viewModel.postProperty(propertyOfferData: propertyOfferData) { postSuccess in
                                            if postSuccess {
                                                print("Propiedad posteada exitosamente.")

                                                viewModel.postOffer(propertyOfferData: propertyOfferData) { offerSuccess in
                                                    if offerSuccess {
                                                        print("Oferta posteada exitosamente.")

                                                        viewModel.uploadImages(for: propertyOfferData) { uploadSuccess in
                                                            if uploadSuccess {
                                                                print("Fotos subidas con éxito.")
                                                                navigateToMainTab = true
                                                            } else {
                                                                print("Error al subir las fotos.")
                                                            }
                                                        }
                                                    } else {
                                                        print("Error al postear la oferta.")
                                                    }
                                                }
                                            } else {
                                                print("Error al postear la propiedad.")
                                            }
                                        }
                                    }
                                } else {
                                    showWarningMessage = true
                                }

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

                if showWarningMessage {
                    VStack {
                        Spacer()
                            .frame(height: 10)

                        Text("Please select a valid date range before proceeding")
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
        }
        .onAppear {
            if propertyOfferData.minutesFromCampus < 5 {
                propertyOfferData.minutesFromCampus = 5
            }

            viewModel.getNextPropertyID { propertyID in
                guard let propertyID = propertyID else {
                    print("Error: No se pudo obtener el siguiente ID de propiedad")
                    return
                }

                propertyOfferData.propertyID = propertyID // Asignar como Int
                print("Next Property ID (onAppear): \(propertyID)")
            }
        }
    }
}

// Reemplazar la función Preview para probar con el ObservableObject
#Preview {
    Step3View(propertyOfferData: PropertyOfferData())
}
