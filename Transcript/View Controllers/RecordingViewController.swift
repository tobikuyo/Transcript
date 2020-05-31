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
    @IBOutlet var scrollView: UIScrollView!

    // MARK: - Properties

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    var transcriptController: TranscriptController?
    var recordingURL: URL?
    var selectedCategory: String?
    let categories = TranscriptCategory.allCases

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        createCategoryPicker()
        createTapGesture()

        titleTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }

    // MARK: - IBActions

    @IBAction func saveTranscript(_ sender: Any) {
        guard
            let title = titleTextField.text, !title.isEmpty,
            let text = transcriptTextView.text,
            let recordingURL = recordingURL,
            let categoryText = categoryTextField.text,
            let category = TranscriptCategory(rawValue: categoryText) else {
                missingPropertiesAlert()
                return
        }

        transcriptController?.createTranscript(title: title, text: text, category: category, recordingURL: recordingURL)
        navigationController?.popViewController(animated: true)
    }

    @IBAction func recordButtonTapped(_ sender: Any) {
        recordButton.isSelected.toggle()

        if recordButton.isSelected {
            requestAuthorization()
            transcriptTextView.text = ""
            transcriptTextView.isEditable = false
        } else {
            stopSpeechRecognition()
            transcriptTextView.isEditable = true

            if transcriptTextView.text == "" {
                transcriptTextView.text = "(Go ahead, I'm listening)"
                transcriptTextView.isEditable = false
                transcriptTextView.isSelectable = false
            }
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
            NSLog("Error processing speech: \(error)")
        }

        guard
            let request = request,
            let speechRecognizer = speechRecognizer,
            speechRecognizer.isAvailable else { return }

        recognitionTask = speechRecognizer.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let transcriptText = result.bestTranscription.formattedString
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

    private func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")

        return file
    }

    // MARK: View Related Methods

    private func updateViews() {
        recordButton.layer.cornerRadius = 45
        titleTextField.textColor = .label
        categoryTextField.textColor = .label
        transcriptTextView.textColor = .label
        titleTextField.font = UIFont(name: "Play-Regular", size: 17)
        categoryTextField.font = UIFont(name: "Play-Regular", size: 17)
        transcriptTextView.font = UIFont(name: "Play-Regular", size: 17)
        transcriptTextView.text = "(Go ahead, I'm listening)"
    }

    private func missingPropertiesAlert() {
        let title = titleTextField.text
        let category = categoryTextField.text
        let transcript = transcriptTextView.text
        
        if title?.count == 0 && category?.count == 0 {
            let alert = UIAlertController(title: "Missing Title and Category", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if title?.count == 0 {
            let alert = UIAlertController(title: "Missing Title", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if category?.count == 0 {
            let alert = UIAlertController(title: "Missing Category", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if transcript?.count == 0 || transcript == "(Go ahead, I'm listening)" {
            let alert = UIAlertController(title: "Missing Transcript", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true) {
                if self.transcriptTextView.text == "" {
                    self.transcriptTextView.text = "(Go ahead, I'm listening)"
                }
            }
        }
    }

    private func createCategoryPicker() {
        let categoryPicker = UIPickerView()
        categoryPicker.delegate = self
        categoryPicker.backgroundColor = .systemBackground
        categoryTextField.inputView = categoryPicker
    }

    private func createTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { notification in
            self.keyboardWillShow(notification: notification)
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { notification in
            self.keyboardWillHide(notification: notification)
        }
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }

        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView?.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: Notification) {
        scrollView?.contentInset = UIEdgeInsets.zero
    }
}

extension RecordingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        label.text = category.capitalized

        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}
