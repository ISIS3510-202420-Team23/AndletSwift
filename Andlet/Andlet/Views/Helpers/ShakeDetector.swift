import UIKit
import SwiftUI
import Combine

// ShakeDetector que usará un UIViewController para capturar el evento
class ShakeDetector: ObservableObject {
    @Published var didShake = false

    // Esta función será llamada por el controlador cuando se detecte el shake
    func deviceShook() {
        DispatchQueue.main.async {
            self.didShake = true
        }
    }

    // Resetea el estado del shake después de que se ha procesado
    func resetShake() {
        DispatchQueue.main.async {
            self.didShake = false
        }
    }
}

// Controlador que detectará el evento shake
class ShakeDetectingViewController: UIViewController {
    var shakeDetector: ShakeDetector?

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            shakeDetector?.deviceShook()
        }
    }
}

// Usamos UIViewControllerRepresentable para integrarlo en SwiftUI
struct ShakeHandlingControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var shakeDetector: ShakeDetector

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = ShakeDetectingViewController()
        controller.shakeDetector = shakeDetector
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Nada que actualizar dinámicamente por ahora
    }
}
