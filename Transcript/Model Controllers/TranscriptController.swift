//
//  TranscriptController.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 27/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import Foundation

class TranscriptController {

    var transcripts: [Transcript] = []

    // MARK: - CRUD Methods

    func createTranscript(title: String,
                          text: String,
                          category: TranscriptCategory,
                          recordingURL: URL) {

        let transcript = Transcript(transcriptTitle: title, text: text, category: category, recordingURL: recordingURL)

        transcripts.append(transcript)
        CoreDataStack.shared.save()
    }

    func updateTranscript(_ transcript: Transcript,
                          title: String,
                          text: String,
                          category: TranscriptCategory,
                          recordingURL: URL) {
        transcript.transcriptTitle = title
        transcript.text = text
        transcript.category = category.rawValue
        transcript.recordingURL = "\(recordingURL)"

        CoreDataStack.shared.save()
    }

    func deleteTrancript(_ transcript: Transcript) {
        CoreDataStack.shared.mainContext.delete(transcript)
        CoreDataStack.shared.save()
    }
}
