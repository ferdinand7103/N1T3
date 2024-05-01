//
//  ContentView.swift
//  LegacyLens
//
//  Created by Ferdinand Jacques on 30/04/24.
//

import SwiftUI
import RealityKit
import ARKit
import AVFoundation
import simd

struct ContentView : View {
    @State private var isListening = false
    @State private var recognizedText = ""
    @State private var animatePulse = false
    @State private var isShowingSceneModel = true
    private let speechService = SpeechRecognizerService()
    @State private var arViewContainer = ARViewContainer(modelName: "SceneMyModel")
    
    var body: some View {
        ZStack(alignment: .bottom){
            ARViewContainer(modelName: isShowingSceneModel ? "SceneMyModel" : "LovePose").edgesIgnoringSafeArea(.all)
            
            HStack {
                Button(action: {
                    print("Toggle button pressed")
                    isShowingSceneModel.toggle()
                    print("Model name toggled to: \(isShowingSceneModel ? "SceneMyModel" : "LovePose")")
                    
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.gray)
                            .opacity(0.4)
                            .frame(width: 70, height: 70)
                        Image(systemName: isShowingSceneModel ? "cube" : "square.grid.2x2.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                Button(action: {
                    takeSnapshot()
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.gray)
                            .opacity(0.4)
                            .frame(width: 70, height: 70)
                        Image(systemName: "camera")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                Button(action: {
                    toggleListening(arViewContainer: arViewContainer)
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.gray)
                            .opacity(0.4)
                            .frame(width: 70, height: 70)
                        Image(systemName: "mic")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(animatePulse ? 1.1 : 1.0)
                .animation(animatePulse ? Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true) : .default, value: animatePulse)
                //                .padding(.leading, 30)
            }
            .padding()
        }
    }
    
    func toggleListening(arViewContainer: ARViewContainer) {
        isListening.toggle()
        
        if isListening {
            animatePulse = true
            do {
                try speechService.startListening { text in
                    DispatchQueue.main.async {
                        if let text = text {
                            self.recognizedText = text
                            print("Recognized Text: \(self.recognizedText)")
                            if self.recognizedText.lowercased() == "what is your most memorable experience" {
                                DispatchQueue.main.async {
                                    arViewContainer.changeVideo()
                                }
                            }
                        } else {
                            self.animatePulse = false
                            self.speechService.stopListening()
                            self.isListening = false
                        }
                    }
                }
            } catch {
                self.isListening = false
                self.animatePulse = false
            }
        } else {
            animatePulse = false
            speechService.stopListening()
        }
    }
    
    
    private func takeSnapshot() {
        ARVariables.arView.snapshot(saveToHDR: false) { image in
            if let image = image {
                let compressedImage = UIImage(data: image.pngData()!)
                UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
            }
        }
    }
}

struct ARVariables{
    static var arView: ARView!
}

struct ARViewContainer: UIViewRepresentable, Equatable {
    static func == (lhs: ARViewContainer, rhs: ARViewContainer) -> Bool {
        return lhs.modelName == rhs.modelName
    }
    
    var modelName: String
    
    func radians(fromDegrees degrees: Float) -> Float {
        return degrees * (.pi / 180)
    }
    
    func makeUIView(context: Context) -> ARView {
        ARVariables.arView = ARView(frame: .zero)
        print("Loading model: \(modelName)")
        
        //------------------------LOAD SCENE DULU, BARU VIDEO DISEBELAH---------------------------//
        let entityModel = (try? Entity.load(named: modelName))!
        
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        
        if modelName == "SceneMyModel" {
            let rotationAngle = radians(fromDegrees: 70)
            entityModel.transform.rotation = simd_quatf(angle: rotationAngle, axis: [0, 1, 0])
        }
        anchor.children.append(entityModel)
        
        ARVariables.arView.scene.anchors.append(anchor)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.addVideo(to: ARVariables.arView)
            print("Out")
        }
        //------------------------LOAD SCENE DULU, BARU VIDEO DISEBELAH---------------------------//
        
        return ARVariables.arView
    }
    
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if modelName != uiView.scene.anchors.first?.children.first?.name {
            uiView.scene.anchors.removeAll()
            
            let entityModel = (try? Entity.load(named: modelName))!
            
            if modelName == "SceneMyModel" {
                let rotationAngle = radians(fromDegrees: 70)
                entityModel.transform.rotation = simd_quatf(angle: rotationAngle, axis: [0, 1, 0])
            }
            
            let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
            anchor.children.append(entityModel)
            
            uiView.scene.anchors.append(anchor)
        }
    }
    
    
    func addVideo(to arView: ARView) {
        if let url = Bundle.main.url(forResource: "test", withExtension: "mp4") {
            let player = AVPlayer(url: url)
            let material = VideoMaterial(avPlayer: player)
            let modelEntity = ModelEntity(mesh: .generateBox(width: 1.0, height: 0.75, depth: 0.01), materials: [material])
            
            player.play()
            
            modelEntity.position.x = -1.7
            modelEntity.position.y = 2.2
            modelEntity.position.z -= 1.7
            let radians = 30 * Float.pi / 180 // Converting degrees to radians
            modelEntity.orientation = simd_quatf(angle: radians, axis: [0, 1, 0])
            
            // Add the video model entity to the scene
            let videoAnchor = AnchorEntity()
            videoAnchor.addChild(modelEntity)
            ARVariables.arView.scene.addAnchor(videoAnchor)
            print("Play")
        }
    }
    
    func changeVideo() {
        guard let arView = ARVariables.arView else {
            print("ARView not initialized")
            return
        }

        // Remove existing video anchor if it exists
        if let existingAnchor = arView.scene.anchors.first(where: { $0.children.contains { $0 is ModelEntity } }) {
            arView.scene.removeAnchor(existingAnchor)
        }

        // Load and add new video
        if let url = Bundle.main.url(forResource: "sampleVideo", withExtension: "mp4") {
            let player = AVPlayer(url: url)
            let videoMaterial = VideoMaterial(avPlayer: player)
            let modelEntity = ModelEntity(mesh: .generateBox(width: 1.0, height: 0.75, depth: 0.01), materials: [videoMaterial])

            // Set position and orientation of the new video
            modelEntity.position.x = -1.7
            modelEntity.position.y = 2.2
            modelEntity.position.z -= 1.7
            let radians = 30 * Float.pi / 180 // Converting degrees to radians
            modelEntity.orientation = simd_quatf(angle: radians, axis: [0, 1, 0])

            // Add the video model entity to the scene
            let videoAnchor = AnchorEntity()
            videoAnchor.addChild(modelEntity)
            arView.scene.addAnchor(videoAnchor)

            // Play the new video
            player.play()
            print("Video changed and started")
        } else {
            print("Failed to load new video")
        }
    }
}

#Preview {
    ContentView()
}
