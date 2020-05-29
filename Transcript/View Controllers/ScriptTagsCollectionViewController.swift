//
//  ScriptTagsCollectionViewController.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 26/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit

class ScriptTagsCollectionViewController: UICollectionViewController {

    @IBOutlet var apperanceButton: UIBarButtonItem!

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

    @IBAction func changeAppearance(_ sender: Any) {
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

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let scriptsTVC = storyboard?.instantiateViewController(identifier: Identifier.scriptsTVC, creator: { coder in
            let category = self.categories[indexPath.item]
            return ScriptsTableViewController(coder: coder, category: category, transcriptController: self.transcriptController)
        }) else { return }

        navigationController?.pushViewController(scriptsTVC, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.addScript {
            if let destinationVC = segue.destination as? RecordingViewController {
                destinationVC.transcriptController = transcriptController
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
