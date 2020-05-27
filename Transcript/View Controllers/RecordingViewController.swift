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

    var selectedCategory: String?
    let categories = Category.allCases

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        createCategoryPicker()
        createTapGesture()
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

    // MARK: - Recording Methods

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

    // MARK: View Related Methods

    private func updateViews() {
        recordButton.layer.cornerRadius = 45
        transcriptTextView.text = "(Go ahead, I'm listening)"
        transcriptTextView.font = UIFont(name: "Play-Regular", size: 16)
        transcriptTextView.textColor = .darkGray
        titleTextField.font = UIFont(name: "Play-Regular", size: 16)
        categoryTextField.font = UIFont(name: "Play-Regular", size: 16)
    }

    private func createCategoryPicker() {
        let categoryPicker = UIPickerView()
        categoryPicker.delegate = self
        categoryPicker.backgroundColor = .white
        categoryTextField.inputView = categoryPicker
    }

    private func createTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
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

extension RecordingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let category = categories[row].rawValue
        return category.capitalized
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let category = categories[row].rawValue
        selectedCategory = category
        categoryTextField.text = selectedCategory?.capitalized
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let category = categories[row].rawValue

        let label = UILabel()
        label.font = UIFont (name: "Play-Regular", size: 23)
        label.textAlignment = .center
        label.text =  category.capitalized

        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}
