//
//  ContentView.swift
//  LegacyLens
//
//  Created by Ferdinand Jacques on 25/04/24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var isListening = false
    @State private var recognizedText = ""
    @State private var animatePulse = false
    private let speechService = SpeechRecognizerService()

    var body: some View {
        VStack(spacing: 20) {
            Text(recognizedText)
                .padding()
            Button(action: toggleListening) {
                ZStack {
                    Circle()
                        .foregroundColor(.gray)
                        .opacity(0.4)
                        .frame(width: 100, height: 100)
                    Image(systemName: "mic")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .scaleEffect(animatePulse ? 1.1 : 1.0)
                .animation(animatePulse ? Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true) : .default, value: animatePulse)
            }
        }
        .onAppear {
            speechService.requestAuthorization { authorized in
                if !authorized {
                    print("Speech recognition authorization denied")
                }
            }
        }
    }

    private func toggleListening() {
        isListening.toggle()
        if isListening {
            animatePulse = true
            try? speechService.startListening { text in
                if let text = text {
                    self.recognizedText = text
                }
            }
        } else {
            animatePulse = false
            speechService.stopListening()
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        // Create a cube model
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.translation.y = 0.05

        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.children.append(model)

        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}
