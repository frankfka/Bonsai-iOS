//
//  AllLogRemindersView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-08-23.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct AllLogRemindersView: View {
    @EnvironmentObject var store: AppStore
    // View models for individual log reminders, extracted to send actions to store
    private var logReminderViewModels: [LogReminderRow.ViewModel] {
        return store.state.globalLogReminders.sortedLogReminders.map { logReminder in
            LogReminderRow.ViewModel(
                logReminder: logReminder,
                onTodoTapped: {
                    self.onTodoTapped(logReminder)
                },
                onRowTapped: {
                    self.onLogReminderRowTapped(logReminder)
                }
            )
        }
    }
    @State(initialValue: false) private var navigateToLogReminderDetails: Bool?

    var body: some View {
        ScrollView {
            VStack {
                // Conditional pushing of navigation views, see RecentLogSection
                NavigationLink(
                    destination: LogReminderDetailView(),
                    tag: true,
                    selection: self.$navigateToLogReminderDetails) {
                    EmptyView()
                }
                // Show all log reminders
                ForEach(self.logReminderViewModels) { reminderVm in
                    Group {
                        LogReminderRow(viewModel: reminderVm)
                        if ViewHelpers.showDivider(after: reminderVm, in: self.logReminderViewModels) {
                            Divider()
                        }
                    }
                }
            }
            .modifier(RoundedBorderSectionModifier())
            .padding(.all, CGFloat.Theme.Layout.Normal)
        }
        .background(Color.Theme.BackgroundPrimary)
        .navigationBarTitle("Log Reminders", displayMode: .inline)
    }

    private func onTodoTapped(_ logReminder: LogReminder) {
        store.send(.createLog(action: .beginInitFromLogReminder(logReminder: logReminder)))
        store.send(.global(action: .changeCreateLogModalDisplay(shouldDisplay: true)))
    }

    private func onLogReminderRowTapped(_ logReminder: LogReminder) {
        store.send(.logReminderDetails(action: .initState(logReminder: logReminder)))
        self.navigateToLogReminderDetails = true
    }
}

struct AllLogRemindersView_Previews: PreviewProvider {
    static var previews: some View {
        AllLogRemindersView()
            .environmentObject(PreviewRedux.filledStore)
    }
}
