////
////  ARViewContainer.swift
////  LegacyLensLite
////
////  Created by Reyhan Ariq Syahalam on 26/04/24.
////
//
//import SwiftUI
//import ARKit
//import AVFoundation
//
//struct ARViewContainer: UIViewRepresentable {
//    @Binding var arView: ARSCNView?
//    @Binding var videoNumber: Int
//    
//    func makeUIView(context: Context) -> ARSCNView {
//        let view = ARSCNView(frame: .zero)
//        view.delegate = context.coordinator
//
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = [.horizontal]
//        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
//            configuration.detectionImages = trackedImages
//            configuration.maximumNumberOfTrackedImages = 1
//        }
//        view.session.run(configuration)
//        print(videoNumber)
//        
//        DispatchQueue.main.async {
//            self.arView = view
//        }
//        
//        return view
//    }
//    
//    func updateUIView(_ uiView: ARSCNView, context: Context) {
//        if let coordinator = uiView.delegate as? Coordinator {
//            coordinator.updateVideoNode()
//        }
//    }
//    
//    static func dismantleUIView(_ uiView: ARSCNView, coordinator: ()) {
//        uiView.session.pause()
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, ARSCNViewDelegate {
//        var parent: ARViewContainer
//        var contentAdded = false
//        
//        init(_ parent: ARViewContainer) {
//            self.parent = parent
//        }
//        
//        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//            guard !contentAdded else { return }
//            
//            if let planeAnchor = anchor as? ARPlaneAnchor {
//                DispatchQueue.main.async { [self] in
//                    let modelNode = self.load3DModel()
//                    modelNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
//                    node.addChildNode(modelNode)
//                    
//                    if parent.videoNumber == 1 {
//                        let videoNode1 = self.addVideoNode(videoName: "sampleVideo")
//                        videoNode1.position = SCNVector3(-0.7, 1.7, planeAnchor.center.z + 0.2)
//                        node.addChildNode(videoNode1)
//                        print(parent.videoNumber)
//                    } else if parent.videoNumber == 2 {
//                        let videoNode2 = self.addVideoNode(videoName: "test")
//                        videoNode2.position = SCNVector3(-0.7, 1.7, planeAnchor.center.z + 0.2)
//                        node.addChildNode(videoNode2)
//                    } else if parent.videoNumber == 3{
//                        let videoNode3 = self.addVideoNode(videoName: "test2")
//                        videoNode3.position = SCNVector3(-0.7, 1.7, planeAnchor.center.z + 0.2)
//                        node.addChildNode(videoNode3)
//                    }
//                    
//                    self.contentAdded = true
//                    renderer.delegate = nil
//                }
//            }
//        }
//        
//        func updateVideoNode() {
//            guard let node = parent.arView?.scene.rootNode else { return }
//            
//            print(parent.videoNumber)
//            
//            if parent.videoNumber == 2 {
//                // Remove existing video nodes
//                node.enumerateChildNodes { (existingNode, _) in
//                    if existingNode.name == "videoNode" {
//                        existingNode.removeFromParentNode()
//                    }
//                }
//                
//                // Add new video node
//                if let planeAnchor = parent.arView?.session.currentFrame?.anchors.first as? ARPlaneAnchor {
//                    let videoNode2 = addVideoNode(videoName: "test")
//                    videoNode2.name = "videoNode"
//                    videoNode2.position = SCNVector3(-0.7, 1.7, planeAnchor.center.z + 0.23)
//                    node.addChildNode(videoNode2)
//                }
//            } else if parent.videoNumber == 3 {
//                // Remove existing video nodes
//                node.enumerateChildNodes { (existingNode, _) in
//                    if existingNode.name == "videoNode" {
//                        existingNode.removeFromParentNode()
//                    }
//                }
//                
//                // Add new video node
//                if let planeAnchor = parent.arView?.session.currentFrame?.anchors.first as? ARPlaneAnchor {
//                    let videoNode3 = addVideoNode(videoName: "test2")
//                    videoNode3.name = "videoNode"
//                    videoNode3.position = SCNVector3(-0.7, 1.7, planeAnchor.center.z + 0.2)
//                    node.addChildNode(videoNode3)
//                }
//            }
//        }
//        
//        func load3DModel() -> SCNNode {
//            guard let scene = SCNScene(named: "SceneMyModel.usdz") else {
//                fatalError("Failed to load the 3D model.")
//            }
//            let modelNode = scene.rootNode.clone()
//            modelNode.eulerAngles.y = .pi / 3.6
//            return modelNode
//        }
//
//        func addVideoNode(videoName: String) -> SCNNode {
//            let videoNode = SCNNode()
//            let videoGeometry = SCNPlane(width: 0.6, height: 0.4)
//            let player = AVPlayer(url: Bundle.main.url(forResource: videoName, withExtension: "mp4")!)
//            player.play()
//            
//            videoGeometry.firstMaterial?.diffuse.contents = player
//            videoNode.geometry = videoGeometry
//            videoNode.eulerAngles.y = 0.7
////            videoNode.position.x = -0.7
////            videoNode.position.y = 1.7
////            videoNode.position.z = 0.2
//            
//            return videoNode
//        }
//    }
//}
