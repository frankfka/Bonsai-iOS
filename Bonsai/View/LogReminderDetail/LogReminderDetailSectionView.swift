//
// Created by Frank Jia on 2020-06-21.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI

extension DateFormatter {
    // Full Date with day of week
    private static var logReminderDetailDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyy"
        return dateFormatter
    }
    // Time in 12hr (ex. 9:00AM)
    private static var logReminderDetailTimeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }
    static func stringForLogReminderDetailDate(from date: Date) -> String {
        return logReminderDetailDateFormatter.string(from: date)
    }
    static func stringForLogReminderDetailTime(from date: Date) -> String {
        return logReminderDetailTimeFormatter.string(from: date)
    }
}

struct LogReminderDetailSectionView: View {

    struct ViewModel {
        private static func getTimeIntervalString(_ interval: TimeInterval) -> String {
            let (valIdx, typeIdx) = TimeInterval.reminderIntervalToSelection(interval)
            let val = TimeInterval.reminderIntervalValueSelections[valIdx]
            let type = TimeInterval.reminderIntervalTypeSelections[typeIdx]
            let typeStr: String
            let valStr = val.strValue
            if val.val > 1 {
                typeStr = type.pluralStrValue
            } else {
                typeStr = type.strValue
            }
            return "\(valStr) \(typeStr)"
        }
        let reminderDate: String
        let reminderTime: String
        let reminderInterval: String
        var showReminderInterval: Bool {
            !self.reminderInterval.isEmptyWithoutWhitespace()
        }
        private let hasNotificationPermissions: Bool
        var showNoNotificationPermissionsText: Bool {
            !hasNotificationPermissions && isPushNotificationEnabledBinding.wrappedValue
        }
        let isPushNotificationEnabledBinding: Binding<Bool>

        init(logReminder: LogReminder, hasNotificationPermissions: Bool, isPushNotificationEnabledBinding: Binding<Bool>) {
            if let interval = logReminder.reminderInterval {
                self.reminderInterval = ViewModel.getTimeIntervalString(interval)
            } else {
                self.reminderInterval = ""
            }
            self.reminderDate = DateFormatter.stringForLogReminderDetailDate(from: logReminder.reminderDate)
            self.reminderTime = DateFormatter.stringForLogReminderDetailTime(from: logReminder.reminderDate)
            self.hasNotificationPermissions = hasNotificationPermissions
            self.isPushNotificationEnabledBinding = isPushNotificationEnabledBinding
        }
    }
    private let viewModel: ViewModel

    init(vm: ViewModel) {
        self.viewModel = vm
    }
    
    private var isPushNotificationEnabledRowVm: ToggleRowView.ViewModel {
        ToggleRowView.ViewModel(
            title: .constant("Push Notification"),
            description: self.viewModel.showNoNotificationPermissionsText ?
                .constant("Notifications permissions are currently disabled. Permissions must be enabled manually in iPhone settings.") :
                .constant(nil),
            value: self.viewModel.isPushNotificationEnabledBinding
        )
    }

    // MARK: Main Body
    var body: some View {
        TitledSection(sectionTitle: "Reminder Details") {
            VStack(spacing: 0) {
                TappableRowView(
                    viewModel: TappableRowView.ViewModel(
                        primaryText: .constant("Reminder Date"),
                        secondaryText: .constant(self.viewModel.reminderDate),
                        hasDisclosureIndicator: false
                    )
                )
                Divider()
                TappableRowView(
                    viewModel: TappableRowView.ViewModel(
                        primaryText: .constant("Reminder Time"),
                        secondaryText: .constant(self.viewModel.reminderTime),
                        hasDisclosureIndicator: false
                    )
                )
                if self.viewModel.showReminderInterval {
                    Divider()
                    TappableRowView(
                        viewModel: TappableRowView.ViewModel(
                            primaryText: .constant("Interval"),
                            secondaryText: .constant(self.viewModel.reminderInterval),
                            hasDisclosureIndicator: false
                        )
                    )
                }
                Divider()
                ToggleRowView(viewModel: self.isPushNotificationEnabledRowVm)
            }
        }
    }
}
