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
                                        text: String,
                                        category: TranscriptCategory,
                                        recordingURL: URL,
                                        dateCreated: Date = Date(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.transcriptTitle = transcriptTitle
        self.text = text
        self.category = category.rawValue
        self.recordingURL = "\(recordingURL)"
        self.dateCreated = dateCreated
    }
}
