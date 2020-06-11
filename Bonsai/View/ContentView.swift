//
//  ContentView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-15.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {

    @EnvironmentObject var store: AppStore

    struct ViewModel {
        var tabIndex: Int = 0
    }

    @State private var viewModel: ViewModel = ViewModel()
    private var tabBarVm: TabBarView.ViewModel {
        TabBarView.ViewModel(
            tabIndex: $viewModel.tabIndex,
            onCreateLogPressed: self.onCreateLogPressed
        )
    }

    // MARK: Main View
    var body: some View {
        // Main view with
        VStack(spacing: 0) {
            if viewModel.tabIndex == 0 {
                HomeTabContainer()
            } else {
                ViewLogsTabContainer()
            }
            TabBarView(viewModel: self.tabBarVm)
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $store.state.global.showCreateLogModal) {
            CreateLogView()
                .environmentObject(self.store)
        }
    }

    // MARK: Actions
    private func onCreateLogPressed() {
        self.store.send(.createLog(action: .resetCreateLogState))
        self.store.send(.global(action: .changeCreateLogModalDisplay(shouldDisplay: true)))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environment(\.colorScheme, .dark)
            ContentView()
        }
        .environmentObject(PreviewRedux.initialStore)
    }
}
