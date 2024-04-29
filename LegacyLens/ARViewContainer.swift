//
//  ARViewContainer.swift
//  LegacyLensLite
//
//  Created by Reyhan Ariq Syahalam on 26/04/24.
//

import SwiftUI
import ARKit
import AVFoundation

struct ARViewContainer: UIViewRepresentable {
    @Binding var arView: ARSCNView?
    
    func makeUIView(context: Context) -> ARSCNView {
        let view = ARSCNView(frame: .zero)
        view.delegate = context.coordinator

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.detectionImages = trackedImages
            configuration.maximumNumberOfTrackedImages = 1
        }
        view.session.run(configuration)

        DispatchQueue.main.async {
            self.arView = view
        }
        
        return view
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    static func dismantleUIView(_ uiView: ARSCNView, coordinator: ()) {
        uiView.session.pause()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARViewContainer
        var contentAdded = false
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard !contentAdded else { return }
            
            if let planeAnchor = anchor as? ARPlaneAnchor {
                DispatchQueue.main.async {
                    let modelNode = self.load3DModel()
                    modelNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
                    node.addChildNode(modelNode)
                    
                    let videoNode = self.addVideoNode()
                    // Adjust position to the right of the model and above it
                    videoNode.position = SCNVector3(planeAnchor.center.x + 0.7, 1.7, planeAnchor.center.z + 0.2)
                    node.addChildNode(videoNode)
                    
                    self.contentAdded = true
                    renderer.delegate = nil // Remove the delegate to prevent further rendering
                }
            }
        }

        func load3DModel() -> SCNNode {
            guard let scene = SCNScene(named: "SceneMyModel.usdz") else {
                fatalError("Failed to load the 3D model.")
            }
            let modelNode = scene.rootNode.clone()
            modelNode.eulerAngles.y = .pi / 3.6  // Rotate 70 degrees to the right (1 radian ≈ 57.3 degrees)
            return modelNode
        }

        func addVideoNode() -> SCNNode {
            let videoNode = SCNNode()
            let videoGeometry = SCNPlane(width: 0.6, height: 0.4)
            let player = AVPlayer(url: Bundle.main.url(forResource: "sampleVideo", withExtension: "mp4")!)
            player.play()
            
            videoGeometry.firstMaterial?.diffuse.contents = player
            videoNode.geometry = videoGeometry
            videoNode.eulerAngles.y = -0.7
            
            return videoNode
        }
    }
}
