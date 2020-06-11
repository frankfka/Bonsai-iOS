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
    struct DaySummary {
        let date: Date
        let averageMoodRankValue: Double? // Nil if none exist for that date
    }
    let moodRankDays: [DaySummary]
    var averageMoodRankValue: Double? {
        moodRankDays.compactMap {
            $0.averageMoodRankValue
        }.getAverage()
    }
}

// MARK: Symptom Severity
struct SymptomSeverityAnalytics {
    struct DaySummary {
        let date: Date
        let averageSeverityValue: Double? // Nil if none exist for that date
    }
    let severityDaySummaries: [DaySummary]
    var averageSeverityValue: Double? {
        severityDaySummaries.compactMap {
            $0.averageSeverityValue
        }.getAverage()
    }
}

// MARK: Helper functions
fileprivate extension Array where Element == Double {
    func getAverage() -> Double? {
        let numValues = self.count
        if numValues == 0 {
            return nil
        }
        return self.reduce(0.0, +) / Double(numValues)
    }
}
