//
// Created by Frank Jia on 2020-03-05.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

struct LogReminder {
    let id: String
    var reminderDate: Date // This is the date on which we should add reminderInterval to get the next reminder
    let reminderInterval: TimeInterval?
    var isRecurring: Bool {
        reminderInterval != nil
    }
    var isOverdue: Bool {
        reminderDate < Date()
    }
    var templateLoggable: Loggable
}
extension LogReminder: Hashable, Equatable, Identifiable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func ==(lhs: LogReminder, rhs: LogReminder) -> Bool {
        return lhs.id == rhs.id
    }
}

class RealmLogReminder: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var reminderDate: Date = Date()
    @objc dynamic var reminderIntervalValue: Double = 0
    @objc dynamic var templateLoggable: RealmLoggable?

    static let reminderDateKey: String = "reminderDate"

    override static func primaryKey() -> String? {
        return "id"
    }
}
