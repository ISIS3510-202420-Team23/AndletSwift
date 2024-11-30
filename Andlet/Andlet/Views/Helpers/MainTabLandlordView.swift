import SwiftUI

struct MainTabLandlordView: View {
    @StateObject private var propertyOfferData = PropertyOfferData() // Instancia de PropertyOfferData

    var body: some View {
        TabView {
            // Pasamos la instancia de propertyOfferData a HomepageRentView
            HomepageRentView()
                .tabItem {
                    Label("Listings", systemImage: "house.fill")
                        .foregroundStyle(Color(hex: "0C356A"))
                }
            NotificationsRentView() // Vista que redirige a las notificaciones
                            .tabItem {
                                Label("Notifications", systemImage: "bell.fill")
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
