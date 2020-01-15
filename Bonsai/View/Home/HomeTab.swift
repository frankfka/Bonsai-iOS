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
        // TODO: Using unmonitored UIColor here
        UINavigationBar.appearance().backgroundColor = .secondarySystemGroupedBackground
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
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                RoundedBorderTitledSection(sectionTitle: "Recent") {
                    RecentLogSection(viewModel: self.getRecentLogSectionViewModel())
                }
            }
            .padding(.all, CGFloat.Theme.Layout.normal)
        }
        // Use flex frame so it always fills width
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
    }
    
    private func getRecentLogSectionViewModel() -> RecentLogSection.ViewModel {
        let logViewModels = store.state.homeScreen.recentLogs.map { LogRow.ViewModel(loggable: $0) }
        return RecentLogSection.ViewModel(recentLogs: logViewModels)
    }
}

//struct HomeTab_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeTab().environmentObject(AppStore(initialState: AppState(), reducer: AppReducer.reduce))
//    }
//}
