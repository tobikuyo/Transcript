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

    let audioEngine = AVAudioEngine()
    let request = SFSpeechAudioBufferRecognitionRequest()

    let speechRecognizer = SFSpeechRecognizer()
    var recognitionTask: SFSpeechRecognitionTask?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Methods

    func recordAndTranscribe() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("Error: \(error)")
        }

        guard
            let speechRecognizer = speechRecognizer,
            speechRecognizer.isAvailable else { return }

        recognitionTask = speechRecognizer.recognitionTask(with: request, resultHandler: { result, error in
            if let error = error {
                NSLog("Error recognising speech: \(error)")
            } else if let result = result {
                let transcript = result.bestTranscription.formattedString
                self.transcriptTextView.text = transcript
            }
        })
    }

    // MARK: - IBActions

    @IBAction func recordButtonTapped(_ sender: Any) {
        recordButton.isSelected.toggle()

        if recordButton.isSelected {
            recordAndTranscribe()
        } 
    }
}
