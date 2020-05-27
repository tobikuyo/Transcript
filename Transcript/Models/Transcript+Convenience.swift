//
//  Transcript+Convenience.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 27/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import Foundation
import CoreData

extension Transcript {
    @discardableResult convenience init(transcriptTitle: String,
                                        transcript: String,
                                        category: Category,
                                        duration: TimeInterval,
                                        currentTime: TimeInterval,
                                        recordingURL: URL,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        guard let urlString = try? String(contentsOf: recordingURL) else {
            fatalError("Error with recording URL")
        }

        self.init(context: context)
        self.transcriptTitle = transcriptTitle
        self.transcript = transcript
        self.category = category.rawValue
        self.duration = duration
        self.currentTime = currentTime
        self.recordingURL = urlString
    }
}
