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
    
    func onCreateLogModalDismiss() {
        self.store.send(.createLog(action: .screenDidDismiss))
    }
    
    func getContentViewModel() -> ContentView.ViewModel {
        return ContentView.ViewModel(
            showCreateLogModal: $viewModel.showCreateLogModal,
            tabIndex: $viewModel.tabIndex,
            tabBarViewModel: getTabBarViewModel(),
            onCreateLogModalDismiss: onCreateLogModalDismiss)
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
        let onCreateLogModalDismiss: VoidCallback
        
        init(showCreateLogModal: Binding<Bool>, tabIndex: Binding<Int>, tabBarViewModel: TabBarView.ViewModel, onCreateLogModalDismiss: @escaping VoidCallback) {
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
            isPresented: viewModel.$showCreateLogModal,
            onDismiss: {
                self.viewModel.onCreateLogModalDismiss()
        }) {
            CreateLogView(
                viewModel: self.getCreateLogViewModel()
            ).environmentObject(self.store)
        }
    }

    // TODO: Complete and use this, cahnge add log to create log
    private func getCreateLogViewModel() -> CreateLogView.ViewModel {
        return CreateLogView.ViewModel(
                showModal: viewModel.$showCreateLogModal,
                isSaveButtonDisabled: !store.state.createLog.isFormValid()
        )
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
