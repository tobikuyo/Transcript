//
//  ScriptTagsCollectionViewController.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 26/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit

class ScriptTagsCollectionViewController: UICollectionViewController {

    // MARK: - Properties

    let transcriptController = TranscriptController()
    let categories = TranscriptCategory.allCases

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.tagCell, for: indexPath) as? ScriptTagCollectionViewCell else {
            return UICollectionViewCell()
        }
    
        let category = categories[indexPath.row]
        let transcripts = transcriptController.transcripts
        cell.category = category
        cell.transcripts = transcripts
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.showScripts {
            if let destinationVC = segue.destination as? ScriptsTableViewController {
                destinationVC.transcriptController = transcriptController
            }
        }

        else if segue.identifier == Identifier.addScript {
            if let destinationVC = segue.destination as? RecordingViewController {
                destinationVC.trancriptController = transcriptController
            }
        }
    }
}

extension ScriptTagsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize (width: collectionView.frame.width * 0.43, height: collectionView.frame.height * 0.27)
        return size
    }
}
