import Speech

class SpeechRecognizerService: NSObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                completion(authStatus == .authorized)
            }
        }
    }

    func startListening(completion: @escaping (String?) -> Void) throws {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            return
        }

        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode  // Directly use without guard
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        recognitionRequest?.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
            var isFinal = false
            if let result = result {
                isFinal = result.isFinal
                completion(result.bestTranscription.formattedString)
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}
