//
// Created by Frank Jia on 2020-02-22.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

// MARK: Master object for analytics shown on common screens
struct LogAnalytics {
    let historicalMoodRank: MoodRankAnalytics?

    init(historicalMoodRank: MoodRankAnalytics? = nil) {
        self.historicalMoodRank = historicalMoodRank
    }
}

// MARK: Mood Rank History
struct MoodRankAnalytics {
    let moodRankDays: [MoodRankDaySummary]
    var averageMoodRankValue: Double? {
        let values = moodRankDays.compactMap {
            $0.averageMoodRankValue
        }
        let numValues = values.count
        if numValues == 0 {
            return nil
        }
        return values.reduce(0.0, +) / Double(numValues)
    }
}
// TODO: Put this inside MoodRankAnalytics
struct MoodRankDaySummary {
    let date: Date
    let averageMoodRankValue: Double? // Nil if none exist for that date
}

// MARK: Symptom Severity
struct SymptomSeverityAnalytics {
    struct DaySummary {
        let date: Date
        let averageSeverityValue: Double? // Nil if none exist for that date
    }
    let severityDaySummaries: [DaySummary]
    // TODO: Extract this into a helper func?
    var averageSeverityValue: Double? {
        let values = severityDaySummaries.compactMap {
            $0.averageSeverityValue
        }
        let numValues = values.count
        if numValues == 0 {
            return nil
        }
        return values.reduce(0.0, +) / Double(numValues)
    }
}