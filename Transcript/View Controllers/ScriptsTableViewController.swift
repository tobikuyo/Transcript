//
//  ScriptsTableViewController.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 31/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import CoreData

class ScriptsTableViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    // MARK: - Properties

    var transcriptController: TranscriptController?
    var category: TranscriptCategory?
    var delegate: ScriptCountDelegate?
    var dateFormatter: DateFormatter?

    lazy var fetchedResultsController: NSFetchedResultsController<TranscriptModel> = {
        let fetchRequest: NSFetchRequest<TranscriptModel> = TranscriptModel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]

        guard let category = category else {
            fatalError("Category was never passed to ScriptsTableViewController")
        }

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

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ScriptsTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let transcripts = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        delegate?.updateCount(with: transcripts)
        return transcripts
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.scriptCell, for: indexPath) as? ScriptTableViewCell else {
            return UITableViewCell()
        }

        let transcript = fetchedResultsController.object(at: indexPath)
        cell.transcript = transcript
        cell.dateFormatter = dateFormatter
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let scriptDetailVC = storyboard?.instantiateViewController(identifier: Identifier.scriptDetailVC, creator: { coder in
            let transcript = self.fetchedResultsController.object(at: indexPath)
            guard let transcriptController = self.transcriptController,
                let dateFormatter = self.dateFormatter else {
                    fatalError("Transcript controller was never passed to ScriptsTableViewController")
            }

            return SciptDetailViewController(coder: coder,
                                             transcript: transcript,
                                             transcriptController: transcriptController,
                                             dateFormatter: dateFormatter)
        }) else { return }

        tableView.deselectRow(at: indexPath, animated: true)

        navigationController?.pushViewController(scriptDetailVC, animated: false)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let transcript = fetchedResultsController.object(at: indexPath)
            transcriptController?.deleteTrancript(transcript)
            guard let count = fetchedResultsController.fetchedObjects?.count else { return }
            delegate?.updateCount(with: count)
            tableView.reloadData()
        }
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
