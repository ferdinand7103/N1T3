//
//  ARViewContainer.swift
//  LegacyLensLite
//
//  Created by Reyhan Ariq Syahalam on 26/04/24.
//

import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var arView: ARSCNView?
    
    func makeUIView(context: Context) -> ARSCNView {
        let view = ARSCNView(frame: .zero)
        view.delegate = context.coordinator
        
        // Menggunakan ARWorldTrackingConfiguration untuk deteksi plane dan gambar
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal] // Deteksi horizontal plane
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.detectionImages = trackedImages
            configuration.maximumNumberOfTrackedImages = 1
        }
        print("ARSession configured for world tracking and image detection.")
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
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                print("Horizontal plane detected")
                DispatchQueue.main.async {
                    let modelNode = self.load3DModel()
                    modelNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
                    node.addChildNode(modelNode)
                    print("3D model of myself added to the scene.")
                }
            }
        }
        
        func load3DModel() -> SCNNode {
            guard let scene = SCNScene(named: "SceneMyModel.usdz") else {
                fatalError("Failed to load the 3D model.")
            }
            let modelNode = scene.rootNode.clone()
            return modelNode
        }
        
        func createCubeNode() -> SCNNode {
            let cubeGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
            cubeGeometry.firstMaterial?.diffuse.contents = UIColor.blue
            let cubeNode = SCNNode(geometry: cubeGeometry)
            print("Created a cube node with dimensions 0.1m x 0.1m x 0.1m.")
            return cubeNode
        }
        
        
        
    }
}
