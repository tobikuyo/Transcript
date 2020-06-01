//
//  ScriptsViewController.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 26/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import CoreData

class ScriptsViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet var backButton: UIButton!
    @IBOutlet var backgroundImage: UIImageView!

    // MARK: - Properties

    let category: TranscriptCategory
    let transcriptController: TranscriptController
    var scriptCountLabel: UILabel!

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Initializers

    init?(coder: NSCoder, category: TranscriptCategory, transcriptController: TranscriptController) {
        self.category = category
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
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Methods

    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    private func updateViews() {
        backgroundImage.image = UIImage(named: "\(category.rawValue.lowercased())Background")
        backgroundImage.contentMode = .scaleAspectFill

        let darkView = UIView()
        darkView.backgroundColor = .black
        darkView.alpha = 0.8
        darkView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.addSubview(darkView)

        NSLayoutConstraint.activate([
            darkView.topAnchor.constraint(equalTo: backgroundImage.topAnchor),
            darkView.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor),
            darkView.bottomAnchor.constraint(equalTo: backgroundImage.bottomAnchor),
            darkView.widthAnchor.constraint(equalTo: backgroundImage.widthAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.text = category.rawValue.uppercased()
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Oswald-Bold", size: 40)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        scriptCountLabel = UILabel()
        scriptCountLabel.textAlignment = .center
        scriptCountLabel.textColor = .white
        scriptCountLabel.font = UIFont(name: "Play-Regular", size: 12)
        scriptCountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scriptCountLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: darkView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: darkView.centerYAnchor),
            scriptCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            scriptCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.showScripts {
            if let destinationVC = segue.destination as? ScriptsTableViewController {
                destinationVC.category = category
                destinationVC.transcriptController = transcriptController
                destinationVC.dateFormatter = dateFormatter
                destinationVC.delegate = self
            }
        }
    }
}

extension ScriptsViewController: ScriptCountDelegate {
    func updateCount(with count: Int) {
         switch count {
         case 0:
             scriptCountLabel.text = "NO TRANSCRIPTS"
         case 1:
             scriptCountLabel.text = "1 TRANSCRIPT"
         default:
             scriptCountLabel.text = "\(count) TRANSCRIPTS"
         }
    }
}
