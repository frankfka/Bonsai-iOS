//
//  LogReminderSection.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-08.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogReminderSection: View {
    
    struct ViewModel {
        static let numToShow = 5  // Number of reminders to show
        let reminders: [LogReminderRow.ViewModel]
        @Binding var navigateToLogReminderDetails: Bool?

        init(logReminders: [LogReminderRow.ViewModel], navigateToLogReminderDetails: Binding<Bool?>) {
            self.reminders = Array(logReminders.prefix(ViewModel.numToShow))
            self._navigateToLogReminderDetails = navigateToLogReminderDetails
        }
    }
    
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            // Conditional pushing of navigation views, see RecentLogSection
            NavigationLink(destination: EmptyView(), tag: true, selection: viewModel.$navigateToLogReminderDetails) {
                // TODO: replace destination
                EmptyView()
            }
            ForEach(viewModel.reminders) { reminderVm in
                Group {
                    LogReminderRow(viewModel: reminderVm)
                    if ViewHelpers.showDivider(after: reminderVm, in: self.viewModel.reminders) {
                        Divider()
                    }
                }
            }
        }
    }
    private func onAppear() {
        viewModel.navigateToLogReminderDetails = nil // Resets navigation state
    }

    private func onLogRowTapped(loggable: Loggable) {
        // TODO: send action to initialize log reminder view state
//        store.send(.logDetails(action: .initState(loggable: loggable)))
        viewModel.navigateToLogReminderDetails = true
    }
}

struct LogReminderSection_Previews: PreviewProvider {

    static private let viewModel: LogReminderSection.ViewModel = LogReminderSection.ViewModel(
            logReminders: [
                LogReminderRow.ViewModel(logReminder: PreviewLogReminders.overdue),
                LogReminderRow.ViewModel(logReminder: PreviewLogReminders.notOverdue)
            ],
            navigateToLogReminderDetails: .constant(nil)
    )

    static var previews: some View {
        Group {
            LogReminderSection(viewModel: viewModel)
        }.previewLayout(.sizeThatFits)
    }
}
