//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct ViewLogsState {
    var isLoading: Bool = false
    var loadError: Error? = nil
    var dateForLogs: Date = Date()
    var allLogs: [Date:[Loggable]] = [:]

    // This ensures proper retrieval/adding of logs
    var logsForSelectedDate: [Loggable] {
        logsForDate(dateForLogs)
    }
    func logsForDate(_ date: Date) -> [Loggable] {
        return allLogs[date.beginningOfDate] ?? []
    }
    mutating func replaceLogs(_ logs: [Loggable], for date: Date? = nil) {
        let selectedDate = (date ?? dateForLogs).beginningOfDate
        allLogs[selectedDate] = logs
    }
    mutating func addLog(log: Loggable, for date: Date? = nil) {
        let selectedDate = (date ?? dateForLogs).beginningOfDate
        // Insert, then sort
        var newLogs: [Loggable] = allLogs[selectedDate] ?? []
        newLogs.append(log)
        newLogs.sort { first, second in first.dateCreated > second.dateCreated } // Descending (latest first)
        allLogs[selectedDate] = newLogs
    }

}