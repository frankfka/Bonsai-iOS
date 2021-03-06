//
//  Mood.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-14.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

// Int values are used for encoding/decoding
enum MoodRank: Int, CaseIterable {
    case negative = -10
    case neutral = 0
    case positive = 10

    var description: String {
        switch self {
        case .negative:
            return "Bad Mood"
        case .neutral:
            return "Neutral Mood"
        case .positive:
            return "Good Mood"
        }
    }
}

struct Mood: LogSearchable {
    let id: String
    let name: String
    let parentCategory: LogCategory = .mood
    let createdBy: String
}

struct MoodLog: Loggable {
    let category: LogCategory = .mood
    let id: String
    let title: String
    let dateCreated: Date
    let notes: String
    let moodRank: MoodRank
}

class RealmMoodLog: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var moodRankRawValue: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}