//
//  LogReminderSection.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-08.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogReminderSection: View {
    @EnvironmentObject var store: AppStore
    
    struct ViewModel {
        static let numToShow = 5  // Number of reminders to show
        let reminders: [LogReminder]
        @Binding var navigateToLogReminderDetails: Bool?
        @Binding var showCreateLogModal: Bool

        init(logReminders: [LogReminder], navigateToLogReminderDetails: Binding<Bool?>,
             showCreateLogModal: Binding<Bool>) {
            self.reminders = Array(logReminders.prefix(ViewModel.numToShow))
            self._navigateToLogReminderDetails = navigateToLogReminderDetails
            self._showCreateLogModal = showCreateLogModal
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
            ForEach(viewModel.reminders) { reminder in
                Group {
                    LogReminderRow(viewModel: self.getLogReminderViewModel(from: reminder))
                    if ViewHelpers.showDivider(after: reminder, in: self.viewModel.reminders) {
                        Divider()
                    }
                }
            }
        }
    }

    private func getLogReminderViewModel(from logReminder: LogReminder) -> LogReminderRow.ViewModel {
        return LogReminderRow.ViewModel(
                logReminder: logReminder,
                onTodoTapped: {
                    self.onTodoTapped(logReminder)
                },
                onRowTapped: {
                    self.onLogRowTapped(logReminder)
                }
        )
    }

    private func onAppear() {
        viewModel.navigateToLogReminderDetails = nil // Resets navigation state
    }

    private func onTodoTapped(_ logReminder: LogReminder) {
        store.send(.createLog(action: .initFromPreviousLog(loggable: logReminder.templateLoggable)))
        viewModel.showCreateLogModal.toggle()
    }

    private func onLogRowTapped(_ logReminder: LogReminder) {
        // TODO: send action to initialize log reminder view state
//        store.send(.logDetails(action: .initState(loggable: loggable)))
//        viewModel.navigateToLogReminderDetails = true
    }
}

struct LogReminderSection_Previews: PreviewProvider {

    static private let viewModel: LogReminderSection.ViewModel = LogReminderSection.ViewModel(
            logReminders: [
                PreviewLogReminders.overdue,
                PreviewLogReminders.notOverdue,
            ],
            navigateToLogReminderDetails: .constant(nil),
            showCreateLogModal: .constant(false)
    )

    static var previews: some View {
        Group {
            LogReminderSection(viewModel: viewModel)
        }.previewLayout(.sizeThatFits)
    }
}
