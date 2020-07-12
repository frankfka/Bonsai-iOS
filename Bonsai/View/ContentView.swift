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

    @State private var tabIndex: Int = 0
    private var tabBarVm: TabBarView.ViewModel {
        TabBarView.ViewModel(
            tabIndex: self.$tabIndex,
            onCreateLogPressed: self.onCreateLogPressed
        )
    }
    
    // MARK: Modal View
    private var modalView: some View {
        Group {
            if self.store.state.global.showCreateLogModal {
                CreateLogView()
            } else if self.store.state.global.showCreateLogReminderModal {
                CreateLogReminderView()
            }
        }
        .environmentObject(self.store)
    }

    // MARK: Main View
    var body: some View {
        // Main view with
        VStack(spacing: 0) {
            if self.tabIndex == 0 {
                HomeTabView()
            } else {
                ViewLogsTabContainer()
            }
            TabBarView(viewModel: self.tabBarVm)
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $store.state.global.showModal) {
            self.modalView
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
