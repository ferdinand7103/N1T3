////
////  ContentView.swift
////  LegacyLens
////
////  Created by Ferdinand Jacques on 25/04/24.
////
//
//import SwiftUI
//import RealityKit
//import ARKit
//import AVFoundation
//
//struct ContentViews: View {
//    @State private var isListening = false
//    @State private var recognizedText = ""
//    @State private var animatePulse = false
//    @State private var arView: ARSCNView?
//    @State private var videoNumber = 1
//    private let speechService = SpeechRecognizerService()
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            ARViewContainer(arView: $arView, videoNumber: $videoNumber)
//                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
//            
//            HStack {
//                // Mic button on the left
//                Button(action: toggleListening) {
//                    ZStack {
//                        Circle()
//                            .foregroundColor(.gray)
//                            .opacity(0.4)
//                            .frame(width: 70, height: 70)
//                        Image(systemName: "mic")
//                            .font(.system(size: 25))
//                            .foregroundColor(.white)
//                    }
//                }
//                .scaleEffect(animatePulse ? 1.1 : 1.0)
//                .animation(animatePulse ? Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true) : .default, value: animatePulse)
//                .padding(.leading, 30) // Adds padding to position the mic button to the far left
//
//                Spacer() // This will push both buttons to the edges
//
//                // Camera button on the right
//                Button(action: takeSnapshot) {
//                    ZStack {
//                        Circle()
//                            .foregroundColor(.gray)
//                            .opacity(0.4)
//                            .frame(width: 70, height: 70)
//                        Image(systemName: "camera")
//                            .font(.system(size: 25))
//                            .foregroundColor(.white)
//                    }
//                }
//                .padding(.trailing, 30) // Adds padding to position the camera button to the far right
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) // Ensures the HStack uses the full width and stays at the bottom
//            .padding(.bottom, 20) // Adds some padding at the bottom
//        }
//        .onAppear {
//            speechService.requestAuthorization { authorized in
//                if !authorized {
//                    print("Speech recognition authorization denied")
//                }
//            }
//        }
//    }
//
//    private func toggleListening() {
//        isListening.toggle()
//        if isListening {
//            animatePulse = true
//            try? speechService.startListening { text in
//                if let text = text {
//                    self.recognizedText = text
//                } else {
//                    animatePulse = false
//                    speechService.stopListening()
//                }
//            }
//        }
//    }
//    
//    func takeSnapshot() {
//        if let image = arView?.snapshot() {
//            let compressedImage = UIImage(data: image.pngData()!)
//            UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
