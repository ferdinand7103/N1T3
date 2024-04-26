//
//  VoiceRecog.swift
//  LegacyLens
//
//  Created by Ferdinand Jacques on 25/04/24.
//

import SwiftUI
import Speech
import AVFoundation

struct VoiceRecog: View {
    @State private var isRecording = false
    @State private var recognizedText = ""
    
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? // Remove @State
    
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!

    var body: some View {
        VStack {
            Text(recognizedText)
                .padding()

            Button(action: {
                if isRecording {
                    self.stopRecording()
                } else {
                    self.startRecording()
                }
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
            }
        }
        .padding()
    }

    private mutating func startRecording() { // Mark the method as mutating
        isRecording = true

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup error: \(error)")
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest() // Initialize recognitionRequest

        guard let recognitionRequest = recognitionRequest else { // Unwrap recognitionRequest
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }

        let inputNode = audioEngine.inputNode

        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let strongSelf = self else { return } // Unwrap self strongly
            
            var isFinal = false

            if let result = result {
                DispatchQueue.main.async {
                    strongSelf.recognizedText = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                DispatchQueue.main.async {
                    strongSelf.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    strongSelf.recognitionRequest = nil
                    strongSelf.recognitionTask = nil
                    strongSelf.isRecording = false
                }
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("Audio engine start error: \(error)")
        }
    }

    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}
