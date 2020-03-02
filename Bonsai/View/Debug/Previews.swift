//
// Created by Frank Jia on 2020-03-01.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

struct AnalyticsPreviews {

    private static var negativeMood: Double = Double(MoodRank.negative.rawValue)
    private static var neutralMood: Double = Double(MoodRank.neutral.rawValue)
    private static var positiveMood: Double = Double(MoodRank.positive.rawValue)

    static var PastWeekWithData: MoodRankAnalytics = MoodRankAnalytics(
            moodRankDays: [
                MoodRankDaySummary(date: Date().addingTimeInterval(-7 * TimeInterval.day), averageMoodRankValue: positiveMood),
                MoodRankDaySummary(date: Date().addingTimeInterval(-6 * TimeInterval.day), averageMoodRankValue: neutralMood),
                MoodRankDaySummary(date: Date().addingTimeInterval(-5 * TimeInterval.day), averageMoodRankValue: negativeMood),
                MoodRankDaySummary(date: Date().addingTimeInterval(-4 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankDaySummary(date: Date().addingTimeInterval(-3 * TimeInterval.day), averageMoodRankValue: neutralMood),
                MoodRankDaySummary(date: Date().addingTimeInterval(-2 * TimeInterval.day), averageMoodRankValue: (negativeMood + neutralMood) / 2.0),
                MoodRankDaySummary(date: Date().addingTimeInterval(-TimeInterval.day), averageMoodRankValue: negativeMood)
            ]
    )

    static var PastWeekWithNoData: MoodRankAnalytics = MoodRankAnalytics(
            moodRankDays: [
                MoodRankDaySummary(date: Date().addingTimeInterval(-7 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankDaySummary(date: Date().addingTimeInterval(-6 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankDaySummary(date: Date().addingTimeInterval(-5 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankDaySummary(date: Date().addingTimeInterval(-4 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankDaySummary(date: Date().addingTimeInterval(-3 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankDaySummary(date: Date().addingTimeInterval(-2 * TimeInterval.day), averageMoodRankValue: nil),
                MoodRankDaySummary(date: Date().addingTimeInterval(-TimeInterval.day), averageMoodRankValue: nil)
            ]
    )
}