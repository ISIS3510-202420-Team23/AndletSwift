import SwiftUI

// Definir un contenedor de navegación que asegure que las vistas internas no hereden configuraciones de layout no deseadas
struct FormContainerView: View {
    var body: some View {
        FormView()
            .navigationBarHidden(true) // Asegura que la barra de navegación no influya en el layout
            .ignoresSafeArea(.all) // Ignorar la safe area en todas las vistas
    }
}

struct FormView: View {
    @StateObject private var navigationState = NavigationState()

    var body: some View {
        NavigationStack {
            Group {
                switch navigationState.currentStep {
                case .step1:
                    Step1View(navigationState: navigationState)
                case .step2:
                    Step2View(navigationState: navigationState)
                case .step3:
                    Step3View(navigationState: navigationState)
                case .profilePicker:
                    ProfilePickerView()
                case .mainTabLandlord:
                    MainTabLandlordView()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Reiniciar el estado de la vista cada vez que FormView aparece
            navigationState.reset()
        }
        .ignoresSafeArea(.all) // Asegura que las configuraciones de safe area no afecten el layout de las sub-vistas
    }
}

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
    }
}
