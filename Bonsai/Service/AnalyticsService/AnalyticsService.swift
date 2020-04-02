//
// Created by Frank Jia on 2020-02-22.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import Combine

protocol AnalyticsService {
    func getAllAnalytics(for user: User) -> ServicePublisher<LogAnalytics>
    func getHistoricalSymptomSeverity(for user: User, with symptomLog: SymptomLog) -> ServicePublisher<SymptomSeverityAnalytics>
}

class AnalyticsServiceImpl: AnalyticsService {
    
    private let db: DatabaseService
    
    init(db: DatabaseService) {
        self.db = db
    }
    
    // MARK: Get All Analytics
    func getAllAnalytics(for user: User) -> ServicePublisher<LogAnalytics> {
        // Get Logs
        let now = Date()
        // TODO: Determine a maximum for log retrieval
        let beginDate = now.addingTimeInterval(-3 * TimeInterval.week)
        // Map the retrieved logs into analytics
        return self.db.getLogs(
            for: user, in: nil, since: beginDate,
            toAndIncluding: now, limit: nil, startingAfterLog: nil, offline: true
        ).map { fetchedLogs in
            return self.getAllAnalytics(from: fetchedLogs, for: user)
        }.mapError { err in
            AppLogging.error("Error retrieving local logs for analytics: \(err)")
            return err
        }.eraseToAnyPublisher()
    }
    
    private func getAllAnalytics(from logs: [Loggable], for user: User) -> LogAnalytics {
        // Categorize the logs
        let logsByType = AppUtils.splitLoggablesByType(logs: logs)
        
        // Get Analytics
        let historicalMoodRank = getHistoricalMoodRank(from: logsByType.moodLogs, numDays: user.settings.analyticsMoodRankDays)
        let analytics = LogAnalytics(historicalMoodRank: historicalMoodRank)
        
        return analytics
    }
    
    private func getHistoricalMoodRank(from logs: [MoodLog], numDays: Int) -> MoodRankAnalytics {
        var moodRankDays: [MoodRankDaySummary] = []
        let now = Date()
        // Calculate for the past 7 days, in reverse order
        for daysInThePast in (0 ..< numDays).reversed() {
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
    
    // MARK: Symptom Severity Analytics
    func getHistoricalSymptomSeverity(for user: User, with symptomLog: SymptomLog) -> ServicePublisher<SymptomSeverityAnalytics> {
        // Get logs up to the date of the log provided, we can customize this at a later time
        return self.db.getLogs(
            for: user, in: .symptom, since: nil,
            toAndIncluding: symptomLog.dateCreated, limit: nil, startingAfterLog: symptomLog, offline: true
        ).map { fetchedLogs in
            return self.getHistoricalSymptomSeverity(initialLog: symptomLog, fetchedLogs: fetchedLogs)
        }.mapError { err in
            AppLogging.error("Error retrieving local logs for analytics: \(err)")
            return err
        }.eraseToAnyPublisher()
    }
    
    private func getHistoricalSymptomSeverity(initialLog: SymptomLog, fetchedLogs: [Loggable]) -> SymptomSeverityAnalytics {
        // Add the loggable back in at the beginning (as startingAfter doesn't include it)
        var matchingSymptomLogs: [SymptomLog] = [initialLog]
        for log in fetchedLogs {
            if log.category == .symptom, let log = log as? SymptomLog, log.symptomId == initialLog.symptomId {
                matchingSymptomLogs.append(log)
            }
        }
        print(matchingSymptomLogs.count)
        return SymptomSeverityAnalytics(severityDaySummaries: [])
    }
    
}
