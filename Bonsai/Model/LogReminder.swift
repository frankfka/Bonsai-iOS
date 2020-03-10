//
// Created by Frank Jia on 2020-03-05.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

struct LogReminder {
    let id: String
    let reminderDate: Date // This is the date on which we should add reminderInterval to get the next reminder
    let reminderInterval: TimeInterval?
    var isRecurring: Bool {
        reminderInterval != nil
    }
    let templateLoggable: Loggable
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
