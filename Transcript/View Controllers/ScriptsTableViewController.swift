//
//  ScriptsTableViewController.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 26/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import CoreData

class ScriptsTableViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet var backButton: UIButton!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var tableView: UITableView!

    // MARK: - Properties

    let category: TranscriptCategory
    let transcriptController: TranscriptController

    lazy var fetchedResultsController: NSFetchedResultsController<TranscriptModel> = {
        let fetchRequest: NSFetchRequest<TranscriptModel> = TranscriptModel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]

        let predicate = NSPredicate(format: "category == %@", category.rawValue)
        fetchRequest.predicate = predicate

        let context = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self

        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch:\(error)")
        }

        return frc
    }()

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
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          navigationController?.setNavigationBarHidden(false, animated: animated)
      }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Methods

    private func updateViews() {
        backgroundImage.image = UIImage(named: "\(category.rawValue.lowercased())Background")
        backgroundImage.contentMode = .scaleAspectFill

        let darkView = UIView()
        darkView.backgroundColor = .black
        darkView.alpha = 0.8
        darkView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.addSubview(darkView)

        NSLayoutConstraint.activate([
            darkView.topAnchor.constraint(equalTo:backgroundImage.topAnchor),
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

        guard let count = fetchedResultsController.fetchedObjects?.count else { return }

        let scriptCountLabel = UILabel()
        scriptCountLabel.textAlignment = .center
        scriptCountLabel.textColor = .white
        scriptCountLabel.font = UIFont(name: "Play-Regular", size: 12)
        scriptCountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scriptCountLabel)

        switch count {
        case 0:
            scriptCountLabel.text = "NO TRANSCRIPTS"
        case 1:
            scriptCountLabel.text = "1 TRANSCRIPT"
        default:
            scriptCountLabel.text = "\(count) TRANSCRIPTS"
        }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: darkView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: darkView.centerYAnchor),
            scriptCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            scriptCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension ScriptsTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let transcripts = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return transcripts
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.scriptCell, for: indexPath)

        let transcript = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = transcript.transcriptTitle

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let scriptDetailVC = storyboard?.instantiateViewController(identifier: Identifier.scriptDetailVC, creator: { coder in
            let transcript = self.fetchedResultsController.object(at: indexPath)
            return SciptDetailViewController(coder: coder, transcript: transcript, transcriptController: self.transcriptController)
        }) else { return }

        tableView.deselectRow(at: indexPath, animated: true)

        navigationController?.pushViewController(scriptDetailVC, animated: false)
    }
}

extension ScriptsTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {

        let sectionSet = IndexSet(integer: sectionIndex)

        switch type {
        case .insert:
            tableView.insertSections(sectionSet, with: .automatic)
        case .delete:
            tableView.deleteSections(sectionSet, with: .automatic)
        default:
            return
        }
    }
}
