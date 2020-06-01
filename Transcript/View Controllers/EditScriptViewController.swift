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

    @IBOutlet var backButton: UIButton!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var categoryTextField: UITextField!
    @IBOutlet var transcriptTextView: UITextView!
    @IBOutlet var scrollView: UIScrollView!

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
        checkInterfaceStyle()
        createCategoryPicker()
        createTapGesture()

        titleTextField.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        addObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        removeObservers()
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
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: View Related Methods

    private func updateViews() {
        titleTextField.textColor = .label
        categoryTextField.textColor = .label
        transcriptTextView.textColor = .label
        titleTextField.font = UIFont(name: "Play-Regular", size: 18)
        categoryTextField.font = UIFont(name: "Play-Regular", size: 18)
        transcriptTextView.font = UIFont(name: "Play-Regular", size: 17)
        transcriptTextView.isEditable = true

        titleTextField.text = transcript.transcriptTitle
        categoryTextField.text = transcript.category
        transcriptTextView.text = transcript.text
    }

    private func checkInterfaceStyle() {
        if self.traitCollection.userInterfaceStyle == .dark {
            backButton.setImage(UIImage(named: "arrows"), for: .normal)
        } else {
            backButton.setImage(UIImage(named: "left-arrow"), for: .normal)
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
        label.font = UIFont(name: "Play-Regular", size: 23)
        label.textAlignment = .center
        label.text =  category.capitalized

        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}

extension EditScriptViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
