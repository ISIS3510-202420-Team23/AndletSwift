import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Step3View: View {
    @ObservedObject var propertyOfferData: PropertyOfferData
    @StateObject private var viewModel = PropertyViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()

    @AppStorage("publishedOffline") private var publishedOffline = false // Almacenar estado offline
    @State private var showNoInternetAlert = false
    @State private var showWarningMessage = false
    @State private var isSaving = false
    @State private var navigateToMainTab = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                if !isSaving {
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

                            Text("Save")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 120, height: 50)
                                .background(isSaving ? Color.gray : Color(red: 12/255, green: 53/255, blue: 106/255))
                                .cornerRadius(15)
                                .onTapGesture {
                                    guard !isSaving else { return }
                                    let todayStartOfDay = Calendar.current.startOfDay(for: Date())

                                    if propertyOfferData.initialDate >= todayStartOfDay && propertyOfferData.finalDate > propertyOfferData.initialDate {
                                        isSaving = true
                                        propertyOfferData.saveToJSON() // Guardar en JSON
                                        
                                        if !networkMonitor.isConnected {
                                            publishedOffline = true // Marcar como publicado sin conexión
                                            showNoInternetAlert = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                                showNoInternetAlert = false
                                                navigateToMainTab = true // Ir a la pantalla principal sin publicar
                                            }
                                        } else {
                                            publishedOffline = false
                                            navigateToMainTab = true // Ir a la pantalla principal directamente
                                        }
                                    } else {
                                        showWarningMessage = true
                                        isSaving = false
                                    }
                                }
                                .disabled(isSaving)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .padding()
                }

                if showNoInternetAlert {
                    ZStack {
                        Color(hex: "#C5DDFF").ignoresSafeArea()
                        VStack(spacing: 20) {
                            Text("⚠️ Your listing will be published once the internet connection is restored")
                                .font(.body)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color(hex: "#FFF4CF"))
                                .cornerRadius(10)
                                .frame(width: 250)
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: showNoInternetAlert)
                }
                
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
            .navigationDestination(isPresented: $navigateToMainTab) {
                MainTabLandlordView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
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

                propertyOfferData.propertyID = propertyID
                print("Next Property ID (onAppear): \(propertyID)")
            }
        }
    }
}
