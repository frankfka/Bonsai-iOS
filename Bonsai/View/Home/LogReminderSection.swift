//
//  LogReminderSection.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-08.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

typealias LogReminderCallback = (LogReminder) -> ()

struct LogReminderSection: View {
    @EnvironmentObject var store: AppStore
    
    struct ViewModel {
        static let numToShow = 5  // Number of reminders to show
        @Binding var navigationState: HomeTabScrollView.NavigationState?
        var logReminderViewModels: [LogReminderRow.ViewModel]
        var showViewAllLogReminders: Bool

        init(store: AppStore, navigationStateBinding: Binding<HomeTabScrollView.NavigationState?>,
             onTodoTapped: @escaping LogReminderCallback, onRowTapped: @escaping LogReminderCallback) {
            self._navigationState = navigationStateBinding
            self.logReminderViewModels = store.state.globalLogReminders.sortedLogReminders.prefix(ViewModel.numToShow).map { logReminder in
                LogReminderRow.ViewModel(
                    logReminder: logReminder,
                    onTodoTapped: {
                        onTodoTapped(logReminder)
                    },
                    onRowTapped: {
                        onRowTapped(logReminder)
                    }
                )
            }
            self.showViewAllLogReminders = store.state.globalLogReminders.sortedLogReminders.count > ViewModel.numToShow
        }
    }

    // Navigation state, initialized by superview
    let navigationStateBinding: Binding<HomeTabScrollView.NavigationState?>
    // Main view model
    private var viewModel: ViewModel {
        ViewModel(
            store: store, navigationStateBinding: navigationStateBinding,
            onTodoTapped: self.onTodoTapped, onRowTapped: self.onLogReminderRowTapped
        )
    }

    init(navigationStateBinding: Binding<HomeTabScrollView.NavigationState?>) {
        self.navigationStateBinding = navigationStateBinding
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
            ForEach(self.viewModel.logReminderViewModels) { reminderVm in
                Group {
                    LogReminderRow(viewModel: reminderVm)
                    if ViewHelpers.showDivider(after: reminderVm, in: self.viewModel.logReminderViewModels) {
                        Divider()
                    }
                }
            }
            if self.viewModel.showViewAllLogReminders {
                // Navigation to all log reminders view
                NavigationLink(destination: {
                    AllLogRemindersView()
                        .environmentObject(self.store)
                }()
                ) {
                    Text("View All")
                        .font(Font.Theme.NormalText)
                        .foregroundColor(Color.Theme.Primary)
                        .padding(.vertical, CGFloat.Theme.Layout.ExtraSmall)
                        .padding(.horizontal, CGFloat.Theme.Layout.Normal)
                }
            }
        }
    }

    private func onTodoTapped(_ logReminder: LogReminder) {
        store.send(.createLog(action: .beginInitFromLogReminder(logReminder: logReminder)))
        store.send(.global(action: .changeCreateLogModalDisplay(shouldDisplay: true)))
    }

    private func onLogReminderRowTapped(_ logReminder: LogReminder) {
        store.send(.logReminderDetails(action: .initState(logReminder: logReminder)))
        viewModel.navigationState = HomeTabScrollView.NavigationState.logReminderDetail
    }
}

struct LogReminderSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LogReminderSection(navigationStateBinding: .constant(nil))
                .environmentObject(PreviewRedux.filledStore)
        }.previewLayout(.sizeThatFits)
    }
}
