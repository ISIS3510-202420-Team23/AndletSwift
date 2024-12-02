import SwiftUI

struct Step2View: View {
    let primaryColor = Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255)
    @ObservedObject var propertyOfferData: PropertyOfferData
    @State private var showWarningMessage = false
    @State private var warningMessageText = "" // Mensaje de advertencia
    @State private var navigateToStep3 = false

    let maxPriceCharacters = 8

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(alignment: .leading) {
                    HeaderView(step: "Step 2", title: "Tell us about your place")

                    VStack(alignment: .leading, spacing: 5) {
                        SelectableOptionsView(
                            selectedOption: Binding<String?>(
                                get: { propertyOfferData.type.rawValue },
                                set: { newValue in
                                    if let newValue = newValue, let newType = OfferType(rawValue: newValue) {
                                        propertyOfferData.type = newType
                                    }
                                }
                            ),
                            options: ["entire_place", "a_room"],
                            displayOptions: ["An entire place", "A room"],
                            title: "What type of place will guests have?"
                        )

                        Text("Let’s be more specific...")
                            .font(.custom("Montserrat-Light", size: 20))
                            .foregroundColor(primaryColor)
                            .padding(.top, 5)

                        VStack(spacing: 15) {
                            IncrementDecrementView(title: "Rooms available for sublet", count: $propertyOfferData.numRooms, maxCount: 5)
                            IncrementDecrementView(title: "Beds", count: $propertyOfferData.numBeds, maxCount: 5)
                            IncrementDecrementView(title: "Bathrooms", count: $propertyOfferData.numBaths, maxCount: 5)
                        }
                        .padding(.bottom, 30)

                        // Campo para el precio por mes
                        PriceField(
                            title: "Now, set your price per month",
                            placeholder: "Enter price",
                            text: Binding(
                                get: { String(format: "%.0f", propertyOfferData.pricePerMonth) },
                                set: { newValue in
                                    if let value = Double(newValue) {
                                        propertyOfferData.pricePerMonth = value
                                    } else {
                                        propertyOfferData.pricePerMonth = 0.0
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

                    HStack {
                        NavigationLink(destination: Step1View(propertyOfferData: propertyOfferData)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(primaryColor)
                                .frame(width: 120, height: 50)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(primaryColor, lineWidth: 2)
                                )
                                .cornerRadius(15)
                        }

                        Spacer()

                        NavigationLink(destination: Step3View(propertyOfferData: propertyOfferData)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true),
                                       isActive: $navigateToStep3) {
                            EmptyView()
                        }
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(primaryColor)
                            .cornerRadius(15)
                            .onTapGesture {
                                if propertyOfferData.type.rawValue.isEmpty || propertyOfferData.pricePerMonth <= 0.0 {
                                    warningMessageText = "Please fill out all required fields before proceeding."
                                    showWarningMessage = true
                                } else if propertyOfferData.pricePerMonth > 10000000 {
                                    warningMessageText = "Price cannot exceed 10 million."
                                    showWarningMessage = true
                                } else {
                                    showWarningMessage = false
                                    navigateToStep3 = true
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
                self.hideKeyboard()
            }
        }
    }
}
