//
//  RecordingViewController.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 27/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import Speech

class RecordingViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var categoryTextField: UITextField!
    @IBOutlet var transcriptTextView: UITextView!
    @IBOutlet var recordButton: UIButton!

    // MARK: - Properties

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioRecorder: AVAudioRecorder?

    var trancriptController: TranscriptController?
    var transcriptTitle: String?
    var transcriptText: String?
    var recordingURL: URL?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }

    // MARK: - IBActions

    @IBAction func saveTranscript(_ sender: Any) {

    }

    @IBAction func recordButtonTapped(_ sender: Any) {
        recordButton.isSelected.toggle()

        if recordButton.isSelected {
            requestAuthorization()
            transcriptTextView.text = ""
        } else {
            stopSpeechRecognition()
        }
    }

    // MARK: - Methods

    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            if status == .authorized {
                self.recordAndTranscribe()
            }
        }
    }

    private func recordAndTranscribe() {
        prepareAudioSession()
        request = SFSpeechAudioBufferRecognitionRequest()

        let recordingURL = createNewRecordingURL()
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            NSLog("Error processing speedch: \(error)")
        }

        guard
            let request = request,
            let speechRecognizer = speechRecognizer,
            speechRecognizer.isAvailable else { return }

        recognitionTask = speechRecognizer.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let transcriptText = result.bestTranscription.formattedString
                self.transcriptText = transcriptText
                self.transcriptTextView.text = transcriptText
                self.recordingURL = recordingURL
            } else if let error = error {
                NSLog("Error recognising speech: \(error)")
            }
        })
    }

    private func stopSpeechRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        request?.endAudio()
        request = nil

        recognitionTask?.cancel()
        recognitionTask = nil
    }

    private func prepareAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            NSLog("An error has occurred while setting the AVAudioSession: \(error)")
        }
    }

    private func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")

        return file
    }

    private func updateViews() {
        recordButton.layer.cornerRadius = 45
        transcriptTextView.text = "(Go ahead, I'm listening)"
        transcriptTextView.font = UIFont(name: "Caudex", size: 18)
        transcriptTextView.textColor = .darkGray
    }
}

extension RecordingViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
}
