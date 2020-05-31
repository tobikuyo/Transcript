//
//  ScriptTableViewCell.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 31/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit

class ScriptTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!

    var dateFormatter: DateFormatter? {
        didSet {
            updateViews()
        }
    }

    var transcript: TranscriptModel? {
        didSet {
            updateViews()
        }
    }

    private func updateViews() {
        guard
            let transcript = transcript,
            let date = transcript.dateCreated,
            let dateFormatter = dateFormatter else { return }

        let dateString = dateFormatter.string(from: date)
        titleLabel.text = transcript.transcriptTitle
        dateLabel.text = dateString.uppercased()
    }
}
