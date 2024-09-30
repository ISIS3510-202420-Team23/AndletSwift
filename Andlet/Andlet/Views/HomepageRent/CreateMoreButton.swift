import SwiftUI

// Actualización de CreateMoreButton
struct CreateMoreButton: View {
    var body: some View {
        HStack {
            Text("Your listings")
                .font(.custom("LeagueSpartan-SemiBold", size: 25))
                .foregroundColor(Color(hex: "0C356A"))
                .fontWeight(.bold)
            Spacer()
            
            // Crear un nuevo PropertyOfferData y pasarlo a Step1View
            NavigationLink(destination: Step1View(propertyOfferData: PropertyOfferData())
                .navigationBarBackButtonHidden()
                .toolbar(.hidden, for: .tabBar)
                .ignoresSafeArea(.all)) {
                Text("+ Create more")
                    .foregroundStyle(.white)
                    .font(.subheadline)
                    .frame(width: 130, height: 45)
                    .background(Color(hex: "0C356A"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

#Preview {
    CreateMoreButton()
}
