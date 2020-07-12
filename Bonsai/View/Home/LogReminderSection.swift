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
        @Binding var navigationState: HomeTabScrollView.NavigationState?

        init(logReminders: [LogReminder], navigationState: Binding<HomeTabScrollView.NavigationState?>) {
            self.reminders = Array(logReminders.prefix(ViewModel.numToShow))
            self._navigationState = navigationState
        }
    }
    
    let viewModel: ViewModel

    // TODO: Some very weird behavior here, if a reminder date changes, viewModel changes but the computed reminder row
    // does not - we need to invalidate the view somehow?
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            // Conditional pushing of navigation views, see RecentLogSection
            NavigationLink(
                    destination: LogReminderDetailView(),
                    tag: HomeTabScrollView.NavigationState.logReminderDetail,
                    selection: viewModel.$navigationState) {
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

    private func onTodoTapped(_ logReminder: LogReminder) {
        store.send(.createLog(action: .beginInitFromLogReminder(logReminder: logReminder)))
        store.send(.global(action: .changeCreateLogModalDisplay(shouldDisplay: true)))
    }

    private func onLogRowTapped(_ logReminder: LogReminder) {
        store.send(.logReminderDetails(action: .initState(logReminder: logReminder)))
        viewModel.navigationState = HomeTabScrollView.NavigationState.logReminderDetail
    }
}

struct LogReminderSection_Previews: PreviewProvider {

    static private let viewModel: LogReminderSection.ViewModel = LogReminderSection.ViewModel(
            logReminders: [
                PreviewLogReminders.overdue,
                PreviewLogReminders.notOverdue,
            ],
            navigationState: .constant(nil)
    )

    static var previews: some View {
        Group {
            LogReminderSection(viewModel: viewModel)
        }.previewLayout(.sizeThatFits)
    }
}
