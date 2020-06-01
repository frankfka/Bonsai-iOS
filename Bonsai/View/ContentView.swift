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
        ContentView(viewModel: getContentViewModel())
    }

    func getContentViewModel() -> ContentView.ViewModel {
        return ContentView.ViewModel(
            showCreateLogModal: $viewModel.showCreateLogModal,
            tabIndex: $viewModel.tabIndex,
            tabBarViewModel: getTabBarViewModel()
        )
    }

    func getTabBarViewModel() -> TabBarView.ViewModel {
        return TabBarView.ViewModel(
            tabIndex: $viewModel.tabIndex,
            onCreateLogPressed: {
                self.store.send(.createLog(action: .resetCreateLogState))
                self.viewModel.showCreateLogModal.toggle()
            }
        )
    }
}

struct ContentView: View {

    @EnvironmentObject var store: AppStore

    struct ViewModel {
        @Binding var showCreateLogModal: Bool
        @Binding var tabIndex: Int
        let tabBarViewModel: TabBarView.ViewModel

        init(showCreateLogModal: Binding<Bool>, tabIndex: Binding<Int>, tabBarViewModel: TabBarView.ViewModel) {
            self._showCreateLogModal = showCreateLogModal
            self._tabIndex = tabIndex
            self.tabBarViewModel = tabBarViewModel
        }
    }

    private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.tabIndex == 0 {
                // TODO: Make viewmodel init inside the container itself
                HomeTabContainer(viewModel: getHomeTabViewModel())
            } else {
                ViewLogsTabContainer()
            }
            TabBarView(viewModel: viewModel.tabBarViewModel)
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(
            isPresented: viewModel.$showCreateLogModal
        ) {
            CreateLogView(
                viewModel: self.getCreateLogViewModel()
            ).environmentObject(self.store)
        }
        .onReceive(self.store.$showCreateLogModal) {
            self.viewModel.showCreateLogModal = $0
        }
    }

    private func getCreateLogViewModel() -> CreateLogView.ViewModel {
        return CreateLogView.ViewModel(
            showModal: viewModel.$showCreateLogModal,
            state: store.state.createLog
        )
    }

    private func getHomeTabViewModel() -> HomeTabContainer.ViewModel {
        let isLoading = store.state.homeScreen.isLoading
        let loadError = store.state.homeScreen.initFailure != nil
        return HomeTabContainer.ViewModel(
            isLoading: isLoading,
            loadError: loadError,
            showCreateLogModal: viewModel.$showCreateLogModal,
            homeTabDidAppear: onShowHomeTab
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
            .environmentObject(PreviewRedux.initialStore)
    }
}
