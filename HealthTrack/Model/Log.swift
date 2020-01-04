//
//  Log.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-11.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

// Protocol that searchable log items conform to
protocol LogSearchable {
    var id: String { get }
    var name: String { get }
    var parentCategory: LogCategory { get }
    var createdBy: String { get }
}

// Protocol that each log type conforms to
protocol Loggable {
    var id: String { get }
    // Add redundant title property to facilitate nosql structure, this way we save a lot of lookups
    var title: String { get }
    var dateCreated: Date { get }
    var category: LogCategory { get }
    var notes: String { get }
}

enum LogCategory: CaseIterable {
    case note
    case symptom
    case nutrition
    case activity
    case mood
    case medication
    
    func displayValue(plural: Bool = false) -> String {
        switch self {
        case .note:
            return "Note" + (plural ? "s" : "")
        case .symptom:
            return "Symptom" + (plural ? "s" : "")
        case .nutrition:
            return "Nutrition"
        case .activity:
            return "Activity" + (plural ? "s" : "")
        case .mood:
            return "Mood" + (plural ? "s" : "")
        case .medication:
            return "Medication" + (plural ? "s" : "")
        }
    }
}
