//
// Created by Frank Jia on 2020-02-22.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import Combine

protocol AnalyticsService {
    func getAllAnalytics(for user: User) -> ServicePublisher<LogAnalytics>
}

class AnalyticsServiceImpl: AnalyticsService {

    private let db: DatabaseService

    init(db: DatabaseService) {
        self.db = db
    }

    func getAllAnalytics(for user: User) -> ServicePublisher<LogAnalytics> {
        // Get Logs
        let now = Date()
        let beginDate = now.addingTimeInterval(-TimeInterval.week)
        // Map the retrieved logs into analytics
        return self.db.getLogs(
            for: user, in: nil, since: beginDate,
            toAndIncluding: now, limit: nil, startingAfterLog: nil, offline: true
        ).map { fetchedLogs in
            return self.getAllAnalytics(from: fetchedLogs)
        }.mapError { err in
            AppLogging.error("Error retrieving local logs for analytics: \(err)")
            return err
        }.eraseToAnyPublisher()
    }

    private func getAllAnalytics(from logs: [Loggable]) -> LogAnalytics {
        // Categorize the logs
        let logsByType = AppUtils.splitLoggablesByType(logs: logs)

        // Get Analytics
        let pastWeekMoodRank = getPastWeekMoodRankAnalytics(from: logsByType.moodLogs)
        let analytics = LogAnalytics(pastWeekMoodRank: pastWeekMoodRank)

        return analytics
    }

    private func getPastWeekMoodRankAnalytics(from logs: [MoodLog]) -> MoodRankAnalytics {
        var moodRankDays: [MoodRankDaySummary] = []
        let now = Date()
        // Calculate for the past 7 days, in reverse order
        for daysInThePast in (0 ..< 7).reversed() {
            let date = now.addingTimeInterval(Double(-daysInThePast) * TimeInterval.day)
            // Get the date
            let moodLogsInDate = logs.filter {
                $0.dateCreated.isInDay(date)
            }
            var averageMoodRank: Double? = nil
            let numMoodLogsInDate = moodLogsInDate.count
            if numMoodLogsInDate > 0 {
                averageMoodRank = moodLogsInDate
                        .map { Double($0.moodRank.rawValue) }
                        .reduce(0.0, +) / Double(numMoodLogsInDate)
            }
            moodRankDays.append(MoodRankDaySummary(date: date, averageMoodRankValue: averageMoodRank))
        }
        return MoodRankAnalytics(moodRankDays: moodRankDays)
    }


}
