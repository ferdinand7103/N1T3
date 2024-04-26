import SwiftUI
import UIKit
import InstantSearchVoiceOverlay

struct SpeechRecogViewController: UIViewControllerRepresentable {
    let voiceOverlayController = VoiceOverlayController()

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            self.recogSound(on: viewController)
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func recogSound(on viewController: UIViewController) {
        voiceOverlayController.start(on: viewController, textHandler: { text, final, _ in
            if final {
                print("Text : \(text)")
            } else {
                print("In Progress : \(text)")
            }
        }, errorHandler: { error in
            // Handle error
        })
    }
}
