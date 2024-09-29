import SwiftUI

struct Step3View: View {
    @ObservedObject var navigationState: NavigationState
    @State private var rooms = 0
    @State private var beds = 0
    @State private var bathrooms = 0
    @State private var pricePerMonth = ""

    // Fechas para el rango
    @State private var startDate = Date()
    @State private var endDate = Date()

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
                            HeaderView(step: "Step 3", title: "Set up your preferences")
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            SelectableOptionsView(
                                options: ["Restrict to Andes", "Any Andlet guest"],
                                title: "Choose who will be your guest",
                                additionalText: "Only users signed in with a @uniandes.edu.co email will be able to contact you"
                            )
                        }
                        .padding(.bottom, 20)
                        .padding(.horizontal)

                        DateRangePickerView(startDate: $startDate, endDate: $endDate)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 20)

                        MinutesFromCampusView()
                            .padding(.bottom, 25)

                        Text("Perfect! You’re all set.\nFinish up\nand publish :)")
                            .font(.custom("Montserrat-Regular", size: 20))
                            .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                            .multilineTextAlignment(.leading)
                            .padding(.top, 30)
                            .padding(.leading, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer() // Este Spacer mantiene el contenido centrado

                        HStack {
                            CustomButton(title: "Back", action: {
                                withAnimation(.easeInOut) {
                                    navigationState.currentStep = .step2
                                }
                            }, isPrimary: false)

                            Spacer()

                            CustomButton(title: "Save", action: {
                                withAnimation(.easeInOut) {
                                    navigationState.currentStep = .mainTabLandlord
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
