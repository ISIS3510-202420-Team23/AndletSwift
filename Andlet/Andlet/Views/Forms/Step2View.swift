import SwiftUI

struct Step2View: View {
    @ObservedObject var navigationState: NavigationState
    @State private var rooms = 0
    @State private var beds = 0
    @State private var bathrooms = 0
    @State private var pricePerMonth = ""

    let maxPriceCharacters = 20

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading) {
                        // Agrega un Spacer en la parte superior para posicionar el contenido
                        Spacer()
                            .frame(height: 20) // Ajusta la altura para controlar la posición vertical

                        VStack(alignment: .leading, spacing: 5) {
                            HeaderView(step: "Step 2", title: "Tell us about your place")
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            SelectableOptionsView(
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

                            IconInputField(
                                title: "Now, set your price per month",
                                placeholder: "Enter price",
                                text: $pricePerMonth,
                                maxCharacters: maxPriceCharacters,
                                height: 50,
                                cornerRadius: 10,
                                iconName: "dollarsign.circle"
                            )
                        }
                        .padding(.horizontal)

                        Spacer() // Este Spacer mantiene el contenido centrado

                        HStack {
                            CustomButton(title: "Back", action: {
                                withAnimation(.easeInOut) {
                                    navigationState.currentStep = .step1
                                }
                            }, isPrimary: false)

                            Spacer()

                            CustomButton(title: "Next", action: {
                                withAnimation(.easeInOut) {
                                    navigationState.currentStep = .step3
                                }
                            }, isPrimary: true)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .padding()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
