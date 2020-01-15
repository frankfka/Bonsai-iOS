//
//  ContentView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-15.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI
import Combine

struct ContentViewContainer: View {
    
    @EnvironmentObject var store: AppStore
    
    struct ViewModel {
        var showCreateLogModal: Bool = false
        var tabIndex: Int = 0
    }
    @State(initialValue: ViewModel()) private var viewModel: ViewModel
    
    var body: some View {
        ContentView(viewModel: getContentViewModel()).environmentObject(self.store)
    }
    
    func getContentViewModel() -> ContentView.ViewModel {
        return ContentView.ViewModel(
            showCreateLogModal: $viewModel.showCreateLogModal,
            tabIndex: $viewModel.tabIndex,
            tabBarViewModel: getTabBarViewModel(),
            onCreateLogModalDismiss: onCreateLogModalDismiss
        )
    }
    
    func onCreateLogModalDismiss() {
        self.store.send(.createLog(action: .screenDidDismiss))
    }
    
    func getTabBarViewModel() -> TabBarView.ViewModel {
        return TabBarView.ViewModel(tabIndex: $viewModel.tabIndex, showCreateLogModal: $viewModel.showCreateLogModal)
    }
}

struct ContentView: View {
    
    @EnvironmentObject var store: AppStore
    struct ViewModel {
        @Binding var showCreateLogModal: Bool
        @Binding var tabIndex: Int
        let tabBarViewModel: TabBarView.ViewModel
        let onCreateLogModalDismiss: VoidCallback?
        
        init(showCreateLogModal: Binding<Bool>, tabIndex: Binding<Int>, tabBarViewModel: TabBarView.ViewModel,
             onCreateLogModalDismiss: VoidCallback? = nil) {
            self._showCreateLogModal = showCreateLogModal
            self._tabIndex = tabIndex
            self.tabBarViewModel = tabBarViewModel
            self.onCreateLogModalDismiss = onCreateLogModalDismiss
        }
    }
    private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            if viewModel.tabIndex == 0 {
                HomeTabContainer(viewModel: getHomeTabViewModel())
                    .environmentObject(self.store)
            } else {
                ViewLogsTabContainer(viewModel: getLogsTabViewModel())
                    .environmentObject(self.store)
            }
            TabBarView(viewModel: viewModel.tabBarViewModel)
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(
            isPresented: viewModel.$showCreateLogModal,
            onDismiss: {
                self.viewModel.onCreateLogModalDismiss?()
        }) {
            CreateLogView(
                viewModel: self.getCreateLogViewModel()
            ).environmentObject(self.store)
        }
    }
    
    private func getCreateLogViewModel() -> CreateLogView.ViewModel {
        let isLoading = store.state.createLog.isCreatingLog
        let createSuccess = store.state.createLog.createSuccess
        let createError = store.state.createLog.createError != nil
        return CreateLogView.ViewModel(
            showModal: viewModel.$showCreateLogModal,
            isFormValid: store.state.createLog.isFormValid(),
            isLoading: isLoading,
            createSuccess: createSuccess,
            createError: createError
        )
    }

    private func getHomeTabViewModel() -> HomeTabContainer.ViewModel {
        let isLoading = store.state.homeScreen.isLoading
        let loadError = store.state.homeScreen.initFailure != nil
        return HomeTabContainer.ViewModel(
                isLoading: isLoading,
                loadError: loadError,
                homeTabDidAppear: onShowHomeTab
        )
    }

    private func getLogsTabViewModel() -> ViewLogsTabContainer.ViewModel {
        return ViewLogsTabContainer.ViewModel(
                isLoading: store.state.viewLogs.isLoading,
                loadError: store.state.viewLogs.loadError != nil,
                viewLogsTabDidAppear: {
                    self.store.send(.viewLog(action: .screenDidShow))
                    self.store.send(.viewLog(action: .fetchData(date: self.store.state.viewLogs.dateForLogs)))
                },
                dateForLogs: store.state.viewLogs.dateForLogs,
                logs: store.state.viewLogs.logs.map { LogRow.ViewModel(loggable: $0) }
        )
    }

    private func onShowHomeTab() {
        self.store.send(.homeScreen(action: .screenDidShow))
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentViewContainer()
                .environment(\.colorScheme, .dark)
            ContentViewContainer()
        }
        .environmentObject(AppStore(initialState: AppState(), reducer: AppReducer.reduce))
    }
}
