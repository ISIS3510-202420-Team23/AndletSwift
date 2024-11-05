import SwiftUI

struct CreateMoreButton: View {
    @AppStorage("publishedOffline") private var publishedOffline = false
    @State var isConnected: Bool // Pasar el estado de conexión
    @State var showOfflineAlert = false // Controla la alerta cuando el botón está desactivado
    
    var body: some View {
        HStack {
            Text("Your listings")
                .font(.custom("LeagueSpartan-SemiBold", size: 25))
                .foregroundColor(Color(hex: "0C356A"))
                .fontWeight(.bold)
            Spacer()
            
            Button(action: {
                if publishedOffline && !isConnected {
                    showOfflineAlert = true // Mostrar la alerta si el botón está desactivado
                }
            }) {
                NavigationLink(destination: Step1View(propertyOfferData: PropertyOfferData())
                    .navigationBarBackButtonHidden()
                    .toolbar(.hidden, for: .tabBar)
                    .ignoresSafeArea(.all)) {
                    Text("+ Create more")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                        .frame(width: 130, height: 45)
                        .background(publishedOffline && !isConnected ? Color.gray : Color(hex: "0C356A"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .disabled(publishedOffline && !isConnected) // Desactiva el botón si se publicó offline y no hay conexión
            .alert(isPresented: $showOfflineAlert) {
                Alert(
                    title: Text("Offline Limit Reached"),
                    message: Text("You can only publish one property without internet connection."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}
