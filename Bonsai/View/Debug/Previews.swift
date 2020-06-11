//
// Created by Frank Jia on 2020-03-01.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

struct AnalyticsPreviews {

    // MARK: Historical Mood
    private static var negativeMood: Double = Double(MoodRank.negative.rawValue)
    private static var neutralMood: Double = Double(MoodRank.neutral.rawValue)
    private static var positiveMood: Double = Double(MoodRank.positive.rawValue)
    static var HistoricalMoodPastWeekWithData: MoodRankAnalytics = MoodRankAnalytics(
            moodRankDays: [
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-7 * TimeInterval.day), averageMoodRankValue: positiveMood),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-6 * TimeInterval.day), averageMoodRankValue: neutralMood),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-5 * TimeInterval.day), averageMoodRankValue: negativeMood),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-4 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-3 * TimeInterval.day), averageMoodRankValue: neutralMood),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-2 * TimeInterval.day), averageMoodRankValue: (negativeMood + neutralMood) / 2.0),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-TimeInterval.day), averageMoodRankValue: negativeMood)
            ]
    )
    static var HistoricalMoodPastWeekWithNoData: MoodRankAnalytics = MoodRankAnalytics(
            moodRankDays: [
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-7 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-6 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-5 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-4 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-3 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-2 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankAnalytics.DaySummary(date: Date().addingTimeInterval(-TimeInterval.day), averageMoodRankValue: nil)
            ]
    )

    // MARK: Historical Symptom Severity
    private static var extremeSeverity: Double = Double(SymptomLog.Severity.extreme.rawValue)
    private static var mildSeverity: Double = Double(SymptomLog.Severity.mild.rawValue)
    private static var noneSeverity: Double = Double(SymptomLog.Severity.none.rawValue)
    static var HistoricalSeverityPastWeek: SymptomSeverityAnalytics = SymptomSeverityAnalytics(
            severityDaySummaries: [
                SymptomSeverityAnalytics.DaySummary(date: Date().addingTimeInterval(-7 * TimeInterval.day), averageSeverityValue: noneSeverity),
                SymptomSeverityAnalytics.DaySummary(date: Date().addingTimeInterval(-6 * TimeInterval.day), averageSeverityValue: noneSeverity),
                SymptomSeverityAnalytics.DaySummary(date: Date().addingTimeInterval(-5 * TimeInterval.day), averageSeverityValue: mildSeverity),
                SymptomSeverityAnalytics.DaySummary(date: Date().addingTimeInterval(-4 * TimeInterval.day), averageSeverityValue: extremeSeverity),
                SymptomSeverityAnalytics.DaySummary(date: Date().addingTimeInterval(-3 * TimeInterval.day), averageSeverityValue: nil),
                SymptomSeverityAnalytics.DaySummary(date: Date().addingTimeInterval(-2 * TimeInterval.day), averageSeverityValue: (extremeSeverity + mildSeverity) / 2.0),
                SymptomSeverityAnalytics.DaySummary(date: Date().addingTimeInterval(-TimeInterval.day), averageSeverityValue: extremeSeverity),
            ]
    )
}