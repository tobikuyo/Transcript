//
//  EditScriptViewController.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 29/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit

class EditScriptViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var categoryTextField: UITextField!
    @IBOutlet var transcriptTextView: UITextView!

    // MARK: - Properties

    let transcript: TranscriptModel
    let transcriptController: TranscriptController
    let categories = TranscriptCategory.allCases
    var selectedCategory: String?

    // MARK: - Initializers

    init?(coder: NSCoder, transcript: TranscriptModel, transcriptController: TranscriptController) {
        self.transcript = transcript
        self.transcriptController = transcriptController
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        createCategoryPicker()
        createTapGesture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - IBActions

    @IBAction func saveTranscript(_ sender: Any) {
        guard
            let title = titleTextField.text, !title.isEmpty,
            let text = transcriptTextView.text,
            let urlString = transcript.recordingURL,
            let recordingURL = URL(string: urlString),
            let categoryText = categoryTextField.text,
            let category = TranscriptCategory(rawValue: categoryText) else { return }

        transcriptController.updateTranscript(transcript, title: title, text: text, category: category, recordingURL: recordingURL)
        navigationController?.popViewController(animated: true)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: View Related Methods

    private func updateViews() {
        titleTextField.textColor = .label
        categoryTextField.textColor = .label
        transcriptTextView.textColor = .label
        titleTextField.font = UIFont(name: "Play-Regular", size: 16)
        categoryTextField.font = UIFont(name: "Play-Regular", size: 16)
        transcriptTextView.font = UIFont(name: "Play-Regular", size: 16)
        transcriptTextView.isEditable = true

        titleTextField.text = transcript.transcriptTitle
        categoryTextField.text = transcript.category
        transcriptTextView.text = transcript.text
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
}

extension EditScriptViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
