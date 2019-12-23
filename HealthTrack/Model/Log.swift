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
}

// Protocol that each log type conforms to
protocol Loggable {
    var category: LogCategory { get }
    var notes: String { get }
}

struct NoteLog: Loggable {
    let category: LogCategory = .note
    let notes: String
}

struct MoodLog: Loggable {
    let category: LogCategory = .mood
    let notes: String
    let moodRank: MoodRank
    let moods: [Mood]
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
