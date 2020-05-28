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

    @IBOutlet var backButton: UIButton!
    @IBOutlet var tableView: UITableView!

    var transcriptController: TranscriptController?

    lazy var fetchedResultsController: NSFetchedResultsController<TranscriptModel> = {
        let fetchRequest: NSFetchRequest<TranscriptModel> = TranscriptModel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]

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

    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.delegate = self
//        tableView.dataSource = self
    }

    @IBAction func backButtonTapped(_ sender: Any) {

    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

//extension ScriptsTableViewController: UITableViewDelegate, UITableViewDataSource {
////    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////
////    }
////
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////
////    }
//}

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
