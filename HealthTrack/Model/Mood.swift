//
//  Mood.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-14.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

// Int values are used for encoding/decoding
enum MoodRank: Int, CaseIterable {
    case negative = -10
    case neutral = 0
    case positive = 10
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