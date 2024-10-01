import SwiftUI
import UIKit

// Subclass of UIView to detect shake gestures
class ShakeDetectingView: UIView {
    var onShake: (() -> Void)?

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake?()
        }
    }
}

// ShakeDetector to integrate with SwiftUI
struct ShakeDetector: UIViewRepresentable {
    var onShake: () -> Void

    func makeUIView(context: Context) -> ShakeDetectingView {
        let view = ShakeDetectingView()
        view.onShake = onShake
        return view
    }

    func updateUIView(_ uiView: ShakeDetectingView, context: Context) {}
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.background(ShakeDetector(onShake: action))
    }
}
