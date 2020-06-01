//
// Created by Frank Jia on 2020-03-05.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

// MARK: LogReminder to Realm
extension RealmService {
    func getRealmLogReminder(from logReminder: LogReminder) -> RealmLogReminder? {
        guard let templateRealmLog = self.getRealmLog(from: logReminder.templateLoggable, isTemplate: true) else {
            AppLogging.warn("Could not create Realm template log from templateLoggable")
            return nil
        }
        let realmLogReminder = RealmLogReminder()
        realmLogReminder.id = logReminder.id
        realmLogReminder.reminderDate = logReminder.reminderDate
        realmLogReminder.reminderIntervalValue = logReminder.reminderInterval?.magnitude ?? 0
        realmLogReminder.templateLoggable = templateRealmLog
        realmLogReminder.isPushNotificationEnabled = logReminder.isPushNotificationEnabled
        return realmLogReminder
    }
}

// MARK: Realm to LogReminder
extension RealmService {
    func getLogReminder(from realmLogReminder: RealmLogReminder) -> LogReminder? {
        guard let realmTemplateLoggable = realmLogReminder.templateLoggable,
              let templateLoggable = self.getLoggable(from: realmTemplateLoggable) else {
            AppLogging.warn("Could not create templateLoggable from Realm template log")
            return nil
        }
        var reminderInterval: TimeInterval? = nil
        if realmLogReminder.reminderIntervalValue > 0 {
            reminderInterval = TimeInterval(realmLogReminder.reminderIntervalValue)
        }
        return LogReminder(
            id: realmLogReminder.id,
            reminderDate: realmLogReminder.reminderDate,
            reminderInterval: reminderInterval,
            templateLoggable: templateLoggable,
            isPushNotificationEnabled: realmLogReminder.isPushNotificationEnabled
        )
    }
}
