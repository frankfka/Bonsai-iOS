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
        var showAddLogModal: Bool = false
        var tabIndex: Int = 0
    }
    @State(initialValue: ViewModel()) private var viewModel: ViewModel
    
    var body: some View {
        ContentView(viewModel: getContentViewModel()).environmentObject(self.store)
    }
    
    func onAddLogModalDismiss() {
        self.store.send(.createLog(action: .screenDidDismiss))
    }
    
    func getContentViewModel() -> ContentView.ViewModel {
        return ContentView.ViewModel(
            showAddLogModal: $viewModel.showAddLogModal,
            tabIndex: $viewModel.tabIndex,
            tabBarViewModel: getTabBarViewModel(),
            onAddLogModalDismiss: onAddLogModalDismiss)
    }
    
    func getTabBarViewModel() -> TabBarView.ViewModel {
        return TabBarView.ViewModel(tabIndex: $viewModel.tabIndex, showAddLogModal: $viewModel.showAddLogModal)
    }
}

struct ContentView: View {
    
    @EnvironmentObject var store: AppStore
    struct ViewModel {
        @Binding var showAddLogModal: Bool
        @Binding var tabIndex: Int
        let tabBarViewModel: TabBarView.ViewModel
        let onAddLogModalDismiss: VoidCallback
        
        init(showAddLogModal: Binding<Bool>, tabIndex: Binding<Int>, tabBarViewModel: TabBarView.ViewModel, onAddLogModalDismiss: @escaping VoidCallback) {
            self._showAddLogModal = showAddLogModal
            self._tabIndex = tabIndex
            self.tabBarViewModel = tabBarViewModel
            self.onAddLogModalDismiss = onAddLogModalDismiss
        }
    }
    private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            if viewModel.tabIndex == 0 {
                HomeTab()
                    .environmentObject(self.store)
            } else {
                Text("Second tab")
                Spacer()
            }
            TabBarView(viewModel: viewModel.tabBarViewModel)
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(
            isPresented: viewModel.$showAddLogModal,
            onDismiss: {
                self.viewModel.onAddLogModalDismiss()
        }) {
            AddLogContainerView(
                showModal: self.viewModel.$showAddLogModal
            ).environmentObject(self.store)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentViewContainer()
                .environment(\.colorScheme, .dark)
            ContentViewContainer()
        }
        .environmentObject(AppStore(initialState: AppState(), reducer: appReducer))
    }
}
