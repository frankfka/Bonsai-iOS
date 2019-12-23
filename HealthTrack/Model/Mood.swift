//
//  Mood.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-14.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

enum MoodRank: CaseIterable {
    case negative
    case neutral
    case positive
}

struct Mood: LogSearchable {
    let id: String
    let name: String
}
