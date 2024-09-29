import SwiftUI

class NavigationState: ObservableObject {
    @Published var currentStep: Step = .step1

    enum Step {
        case step1, step2, step3, profilePicker, mainTabLandlord
    }

    // Agregar una función de reinicio
    func reset() {
        currentStep = .step1
    }
}
