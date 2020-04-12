//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct GlobalLogState {
    // Analytics - global object so this is accessible by all views
    var analytics: LogAnalytics? = nil
    var isLoadingAnalytics: Bool = false
    var loadAnalyticsError: Error? = nil
    // All logs by date
    var logsByDate: [Date: [Loggable]] = [:]
    var sortedLogs: [Loggable] {
        logsByDate
            // Sort by reverse chronological keys
            .sorted(by: { first, second in first.key > second.key })
            // Flat map to sorted loggables
            .flatMap { date, loggables in
                // Sort individual loggables by date
                loggables.sorted(by: { first, second in first.dateCreated > second.dateCreated })
            }
    }
    // Specifies whether we have retrieved all the logs for a specific date
    private var retrieved: Set<Date> = []

    func getLogs(for date: Date) -> [Loggable] {
        if let logs = logsByDate[date.beginningOfDate] {
            return logs
        }
        // This is currently a non-issue, as we retrieve from global logs, but the action to update log state
        // might not have fired yet. This method will be called again when the log store is reinitialized
        return []
    }

    // Determine whether logs for a certain date has been retrieved
    func hasBeenRetrieved(_ date: Date) -> Bool {
        return retrieved.contains(date.beginningOfDate)
    }

    // Determine whether in a date range has been retrieved
    func hasBeenRetrieved(from startDate: Date, toAndIncluding: Date) -> Bool {
        var checkDate: Date = startDate
        while checkDate < toAndIncluding {
            if !self.hasBeenRetrieved(checkDate) {
                return false
            }
            checkDate = checkDate.addingTimeInterval(.day)
        }
        return true
    }

    // Mark a specific date as having been retrieved
    mutating func markAsRetrieved(for dates: [Date]) {
        for date in dates {
            retrieved.insert(date.beginningOfDate)
        }
    }

    // Insert a log
    mutating func insert(_ log: Loggable) {
        let logDate = log.dateCreated.beginningOfDate
        // Insert, then sort
        var logsForDate: [Loggable] = logsByDate[logDate] ?? []
        logsForDate.append(log)
        logsForDate.sort { first, second in first.dateCreated > second.dateCreated } // Descending (latest first)
        logsForDate = deduplicateLogs(logsForDate) // Deduplicate logs
        // Put back into dict
        logsByDate[logDate] = logsForDate
    }

    private func deduplicateLogs(_ logs: [Loggable]) -> [Loggable] {
        var deduplicatedLogs: [Loggable] = []
        for log in logs {
            if deduplicatedLogs.firstIndex(where: {$0.id == log.id}) == nil {
                deduplicatedLogs.append(log)
            }
        }
        return deduplicatedLogs
    }

    // Replace an entire dict entry
    mutating func replace(logs: [Loggable], for date: Date) {
        logsByDate[date.beginningOfDate] = logs
    }

    // Delete a log from logs
    mutating func delete(_ log: Loggable) {
        let logDate = log.dateCreated.beginningOfDate
        let logsForDate: [Loggable] = (logsByDate[logDate] ?? []).filter { $0.id != log.id }
        logsByDate[logDate] = logsForDate
    }

}
