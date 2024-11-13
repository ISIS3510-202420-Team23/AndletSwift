import SwiftUI

struct MainTabLandlordView: View {
    @StateObject private var propertyOfferData = PropertyOfferData() // Instancia de PropertyOfferData

    var body: some View {
        TabView {
            // Pasamos la instancia de propertyOfferData a HomepageRentView
            HomepageRentView()
                .tabItem {
                    Label("Explore", systemImage: "location.fill")
                        .foregroundStyle(Color(hex: "0C356A"))
                }
        }
        .accentColor(Color(hex: "0C356A"))
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.white
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundImage = UIImage()
        }
    }
}
