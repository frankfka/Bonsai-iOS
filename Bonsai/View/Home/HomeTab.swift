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
                trailing: NavigationLink(destination: SettingsView().environmentObject(store)) {
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
        return HomeTab.ViewModel()
    }
}

struct HomeTab: View {
    @EnvironmentObject var store: AppStore
    
    struct ViewModel {
        
    }
    private let viewModel: ViewModel
    @State(initialValue: false) var navigateToLogDetails: Bool? // Allows conditional pushing of navigation views
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CGFloat.Theme.Layout.large) {
                RoundedBorderTitledSection(sectionTitle: "Recent") {
                    RecentLogSection(viewModel: self.getRecentLogSectionViewModel())
                }
                // TODO: still need to make sure this updates on new log entry
                RoundedBorderTitledSection(sectionTitle: "Your Mood") {
                    MoodAnalyticsSection(viewModel: self.getMoodAnalyticsSectionViewModel())
                }
            }
            .padding(.all, CGFloat.Theme.Layout.normal)
        }
    }
    
    private func getRecentLogSectionViewModel() -> RecentLogSection.ViewModel {
        let logViewModels = store.state.homeScreen.recentLogs.map { LogRow.ViewModel(loggable: $0) }
        return RecentLogSection.ViewModel(
                recentLogs: logViewModels,
                navigateToLogDetails: $navigateToLogDetails
        )
    }

    private func getMoodAnalyticsSectionViewModel() -> MoodAnalyticsSection.ViewModel {
        let pastWeekChartViewModel: PastWeekMoodChartView.ViewModel?
        if let moodRankAnalytics = store.state.homeScreen.analytics?.pastWeekMoodRank {
            pastWeekChartViewModel = PastWeekMoodChartView.ViewModel(analytics: moodRankAnalytics)
        } else {
            pastWeekChartViewModel = nil
        }
        let isLoading = store.state.homeScreen.isLoadingAnalytics
        let loadError = store.state.homeScreen.loadAnalyticsError != nil
        return MoodAnalyticsSection.ViewModel(
                chartViewModel: pastWeekChartViewModel,
                isLoading: isLoading,
                loadError: loadError
        )
    }

}

//struct HomeTab_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeTab().environmentObject(AppStore(initialState: AppState(), reducer: AppReducer.reduce))
//    }
//}
