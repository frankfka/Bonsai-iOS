//
//  RootView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-10.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        let isLoading: Bool
        let loadError: Bool
    }
    private var viewModel: ViewModel {
        ViewModel(
            isLoading: store.state.global.isInitializing,
            loadError: store.state.global.initError != nil
        )
    }
    
    // Start screen for app, will show loading if app is still initializing
    // Will also be used for other global error states
    var body: some View {
        Group {
            if viewModel.isLoading {
                FullScreenLoadingSpinner(isOverlay: false)
            } else if viewModel.loadError {
                FullScreenErrorView()
            } else {
                // The content view for all of the app
                ContentView()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(PreviewRedux.initialStore)
    }
}
