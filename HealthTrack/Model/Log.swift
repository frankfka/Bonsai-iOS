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

struct NoteLog: Loggable {
    let category: LogCategory = .note
    let id: String
    let title: String
    let dateCreated: Date
    let notes: String
}

struct MoodLog: Loggable {
    let category: LogCategory = .mood
    let id: String
    let title: String
    let dateCreated: Date
    let notes: String
    let moodRank: MoodRank
}

struct MedicationLog: Loggable {
    let category: LogCategory = .medication
    let id: String
    let title: String
    let dateCreated: Date
    let notes: String
    let medicationId: String
    let dosage: String
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
            return "Nutrition" + (plural ? "s" : "")
        case .activity:
            return "Activity" + (plural ? "s" : "")
        case .mood:
            return "Mood" + (plural ? "s" : "")
        case .medication:
            return "Medication" + (plural ? "s" : "")
        }
    }
}
