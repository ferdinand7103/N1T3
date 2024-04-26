//
//  ContentView.swift
//  LegacyLens
//
//  Created by Ferdinand Jacques on 25/04/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State private var isSpeechRecogActive = false
    
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
        Button(action: {
            isSpeechRecogActive.toggle()
        }) {
            ZStack {
                Circle()
                    .foregroundColor(.gray)
                    .opacity(0.4)
                    .frame(width: 100, height: 100)
                Image(systemName: "mic")
                    .font(.system(size: 40))
            }
        }
        if isSpeechRecogActive {
            SpeechRecogViewController()
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
