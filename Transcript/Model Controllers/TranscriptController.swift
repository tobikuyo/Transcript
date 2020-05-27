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
                          category: Category,
                          duration: TimeInterval,
                          currentTime: TimeInterval,
                          recordingURL: URL) {

        let transcript = Transcript(transcriptTitle: title, text: text, category: category, duration: duration, currentTime: currentTime, recordingURL: recordingURL)

        transcripts.append(transcript)
        CoreDataStack.shared.save()
    }

    func updateTranscript(_ transcript: Transcript,
                          title: String,
                          text: String,
                          category: Category,
                          duration: TimeInterval,
                          currentTime: TimeInterval,
                          recordingURL: URL) {
        transcript.transcriptTitle = title
        transcript.text = text
        transcript.category = category.rawValue
        transcript.duration = duration
        transcript.currentTime = currentTime
        transcript.recordingURL = "\(recordingURL)"

        CoreDataStack.shared.save()
    }

    func deleteTrancript(_ transcript: Transcript) {
        CoreDataStack.shared.mainContext.delete(transcript)
        CoreDataStack.shared.save()
    }
}
