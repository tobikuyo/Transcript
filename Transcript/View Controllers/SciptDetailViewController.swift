//
//  SciptDetailViewController.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 26/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit

class SciptDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var transcriptTextView: UITextView!
    
    // MARK: - Properties
    
    let transcript: TranscriptModel
    let transcriptController: TranscriptController
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        guard let editScriptVC = storyboard?.instantiateViewController(identifier: Identifier.editScriptVC, creator: { coder in
            return EditScriptViewController(coder: coder, transcript: self.transcript, transcriptController: self.transcriptController)
        }) else { return }

        navigationController?.pushViewController(editScriptVC, animated: true)
    }

    @IBAction func shareButtonTapped(_ sender: Any) {
        guard
            let title = transcript.transcriptTitle,
            let text = transcript.text else { return }
        let transcriptPDF = TranscriptPDF(title: title, text: text)
        let data = transcriptPDF.createTranscript()
        let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)
    }

    // MARK: - Methods
    
    private func updateViews() {
        guard let category = transcript.category?.lowercased() else { return }
        backgroundImage.image = UIImage(named: "\(category)Background")
        backgroundImage.contentMode = .scaleAspectFill
        transcriptTextView.text = transcript.text
        transcriptTextView.font = UIFont(name: "Caudex", size: 18)
        transcriptTextView.textColor = .label
        transcriptTextView.isEditable = false
        
        let darkView = UIView()
        darkView.backgroundColor = .black
        darkView.alpha = 0.8
        darkView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.addSubview(darkView)
        
        NSLayoutConstraint.activate([
            darkView.topAnchor.constraint(equalTo:backgroundImage.topAnchor),
            darkView.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor),
            darkView.bottomAnchor.constraint(equalTo: backgroundImage.bottomAnchor, constant: 2),
            darkView.widthAnchor.constraint(equalTo: backgroundImage.widthAnchor)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = transcript.transcriptTitle?.uppercased()
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Oswald-Bold", size: 30)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let dateLabel = UILabel()
        guard let date = transcript.dateCreated else { return }
        dateLabel.text = dateFormatter.string(from: date).uppercased()
        dateLabel.textAlignment = .center
        dateLabel.textColor = .white
        dateLabel.font = UIFont(name: "Play-Regular", size: 12)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateLabel)

        shareButton.tintColor = .white
        shareButton.titleLabel?.font = UIFont(name: "Play-Regular", size: 12)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            titleLabel.centerYAnchor.constraint(equalTo: darkView.centerYAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
