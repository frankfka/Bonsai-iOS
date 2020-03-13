//
//  HomeTab.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct HomeTabContainer: View {
    @EnvironmentObject var store: AppStore
    
    struct ViewModel {
        let isLoading: Bool
        let loadError: Bool
        let homeTabDidAppear: VoidCallback?
        @Binding var showCreateLogModal: Bool

        init(isLoading: Bool, loadError: Bool, showCreateLogModal: Binding<Bool>, homeTabDidAppear: VoidCallback? = nil) {
            self.isLoading = isLoading
            self.loadError = loadError
            self._showCreateLogModal = showCreateLogModal
            self.homeTabDidAppear = homeTabDidAppear
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if self.viewModel.isLoading {
                FullScreenLoadingSpinner(isOverlay: false)
            } else if self.viewModel.loadError {
                ErrorView()
            } else {
                HomeTab(viewModel: self.getHomeTabViewModel())
            }
        }
        .onAppear {
            self.viewModel.homeTabDidAppear?()
        }
        .background(Color.Theme.backgroundPrimary)
        .navigationBarTitle("Home")
        .navigationBarItems(
                trailing: NavigationLink(destination: SettingsView()) {
                    Image(systemName: "person.crop.circle")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(height: CGFloat.Theme.Layout.navBarItemHeight)
                            .foregroundColor(Color.Theme.primary)
                }
        )
        .embedInNavigationView()
        .padding(.top) // Temporary - bug where scrollview goes under the status bar
    }
    
    func getHomeTabViewModel() -> HomeTab.ViewModel {
        // TODO: Show empty text instead?
        // TODO: Limit to only today?
        let showReminders = !store.state.globalLogReminders.sortedLogReminders.isEmpty
        return HomeTab.ViewModel(
            showReminders: showReminders,
            showCreateLogModal: viewModel.$showCreateLogModal
        )
    }
}

struct HomeTab: View {
    @EnvironmentObject var store: AppStore
    
    struct ViewModel {
       let showReminders: Bool
        @Binding var showCreateLogModal: Bool

        init(showReminders: Bool, showCreateLogModal: Binding<Bool>) {
            self.showReminders = showReminders
            self._showCreateLogModal = showCreateLogModal
        }
    }
    private let viewModel: ViewModel
    @State(initialValue: false) var navigateToLogDetails: Bool? // Allows conditional pushing of navigation views
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CGFloat.Theme.Layout.large) {
                if viewModel.showReminders {
                    RoundedBorderTitledSection(sectionTitle: "Reminders") {
                        LogReminderSection(viewModel: self.getLogReminderSectionViewModel())
                    }
                }
                RoundedBorderTitledSection(sectionTitle: "Recent") {
                    RecentLogSection(viewModel: self.getRecentLogSectionViewModel())
                }
                RoundedBorderTitledSection(sectionTitle: "Your Mood") {
                    MoodAnalyticsSection(viewModel: self.getMoodAnalyticsSectionViewModel())
                }
            }
            .padding(.all, CGFloat.Theme.Layout.normal)
        }
    }

    private func getLogReminderSectionViewModel() -> LogReminderSection.ViewModel {
        let reminderViewModels =
                Array(store.state.globalLogReminders.sortedLogReminders.prefix(LogReminderSection.ViewModel.numToShow))
                        .map { LogReminderRow.ViewModel(logReminder: $0) }
        return LogReminderSection.ViewModel(
                logReminders: reminderViewModels,
                navigateToLogReminderDetails: $navigateToLogDetails
        )
    }
    
    private func getRecentLogSectionViewModel() -> RecentLogSection.ViewModel {
        let logViewModels =
                Array(store.state.globalLogs.sortedLogs.prefix(RecentLogSection.ViewModel.numToShow))
                        .map { LogRow.ViewModel(loggable: $0) }
        return RecentLogSection.ViewModel(
                recentLogs: logViewModels,
                navigateToLogDetails: $navigateToLogDetails
        )
    }

    private func getMoodAnalyticsSectionViewModel() -> MoodAnalyticsSection.ViewModel {
        let pastWeekChartViewModel: PastWeekMoodChartView.ViewModel?
        if let moodRankAnalytics = store.state.globalLogs.analytics?.pastWeekMoodRank {
            pastWeekChartViewModel = PastWeekMoodChartView.ViewModel(analytics: moodRankAnalytics)
        } else {
            pastWeekChartViewModel = nil
        }
        let isLoading = store.state.globalLogs.isLoadingAnalytics
        let loadError = store.state.globalLogs.loadAnalyticsError != nil
        return MoodAnalyticsSection.ViewModel(
                chartViewModel: pastWeekChartViewModel,
                isLoading: isLoading,
                loadError: loadError
        )
    }

}

struct HomeTab_Previews: PreviewProvider {
    static var previews: some View {
        HomeTab(viewModel: HomeTab.ViewModel(
                showReminders: true,
                showCreateLogModal: .constant(false)
        )).environmentObject(PreviewRedux.initialStore)
    }
}
