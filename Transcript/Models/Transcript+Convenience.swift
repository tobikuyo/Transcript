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
                                        category: Category,
                                        duration: TimeInterval,
                                        currentTime: TimeInterval,
                                        recordingURL: URL,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.transcriptTitle = transcriptTitle
        self.text = text
        self.category = category.rawValue
        self.duration = duration
        self.currentTime = currentTime
        self.recordingURL = "\(recordingURL)"
    }
}
