//
//  HomeTab.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var store: AppStore

    // MARK: View Model
    struct ViewModel {
        let isLoading: Bool
        let loadError: Bool

        init(isLoading: Bool, loadError: Bool) {
            self.isLoading = isLoading
            self.loadError = loadError
        }
    }

    private var viewModel: ViewModel {
        let isLoading = store.state.homeScreen.isLoading
        let loadError = store.state.homeScreen.initFailure != nil
        return HomeTabView.ViewModel(
            isLoading: isLoading,
            loadError: loadError
        )
    }

    // MARK: Views
    @ViewBuilder
    var viewForState: some View {
        if self.viewModel.isLoading {
            FullScreenLoadingSpinner(isOverlay: false)
        } else if self.viewModel.loadError {
            FullScreenErrorView()
        } else {
            HomeTabScrollView()
        }
    }

    // Mark: Main View
    var body: some View {
        viewForState
            .onAppear(perform: self.homeTabDidAppear)
            .background(Color.Theme.BackgroundPrimary)
            .navigationBarTitle("Home")
            .navigationBarItems(
                trailing: NavigationLink(destination: SettingsView()) {
                    Image.Icons.PersonCropCircle
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height: CGFloat.Theme.Layout.NavBarItemHeight)
                        .foregroundColor(Color.Theme.Primary)
                }
            )
            .embedInNavigationView()
    }

    func homeTabDidAppear() {
        self.store.send(.homeScreen(action: .screenDidShow))
    }
}

struct HomeTabScrollView: View {
    @EnvironmentObject var store: AppStore

    // MARK: View model
    struct ViewModel {
        let showReminders: Bool

        init(showReminders: Bool) {
            self.showReminders = showReminders
        }
    }
    private var viewModel: ViewModel {
        // TODO: Limit to only today? - or a setting to determine how much to show
        ViewModel(
            showReminders: !store.state.globalLogReminders.sortedLogReminders.isEmpty
        )
    }

    @State(initialValue: nil) var navigationState: NavigationState? // Allows conditional pushing of navigation views
    enum NavigationState {
        case logDetail
        case logReminderDetail
    }

    // MARK: Main View
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CGFloat.Theme.Layout.Large) {
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
            .padding(.all, CGFloat.Theme.Layout.Normal)
        }
    }

    private func getLogReminderSectionViewModel() -> LogReminderSection.ViewModel {
        return LogReminderSection.ViewModel(
            logReminders: store.state.globalLogReminders.sortedLogReminders,
            navigationState: self.$navigationState
        )
    }

    private func getRecentLogSectionViewModel() -> RecentLogSection.ViewModel {
        return RecentLogSection.ViewModel(
            recentLogs: store.state.globalLogs.sortedLogs,
            navigationState: $navigationState
        )
    }

    private func getMoodAnalyticsSectionViewModel() -> MoodAnalyticsSection.ViewModel {
        let pastWeekChartViewModel: HistoricalMoodChartView.ViewModel?
        if let moodRankAnalytics = store.state.globalLogs.analytics?.historicalMoodRank {
            pastWeekChartViewModel = HistoricalMoodChartView.ViewModel(analytics: moodRankAnalytics)
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
        HomeTabScrollView()
            .background(Color.Theme.BackgroundPrimary)
            .environmentObject(PreviewRedux.initialStore)
    }
}
