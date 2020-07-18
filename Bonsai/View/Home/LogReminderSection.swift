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
        @Binding var navigationState: HomeTabScrollView.NavigationState?

        init(navigationState: Binding<HomeTabScrollView.NavigationState?>) {
            self._navigationState = navigationState
        }
    }
    private let viewModel: ViewModel
    private var logReminderViewModels: [LogReminderRow.ViewModel] {
        return store.state.globalLogReminders.sortedLogReminders.prefix(ViewModel.numToShow).map { logReminder in
            LogReminderRow.ViewModel(
                logReminder: logReminder,
                onTodoTapped: {
                    self.onTodoTapped(logReminder)
                },
                onRowTapped: {
                    self.onLogRowTapped(logReminder)
                }
            )
        }
    }

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
            ForEach(self.logReminderViewModels) { reminderVm in
                Group {
                    LogReminderRow(viewModel: reminderVm)
                    if ViewHelpers.showDivider(after: reminderVm, in: self.logReminderViewModels) {
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
            navigationState: .constant(nil)
    )

    static var previews: some View {
        Group {
            LogReminderSection(viewModel: viewModel)
                .environmentObject(PreviewRedux.filledStore)
        }.previewLayout(.sizeThatFits)
    }
}
