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
    
    // Start screen for app, will show loading if app is still initializing
    // Will also be used for other global error states
    var body: some View {
        ZStack {
            if store.state.global.isInitializing {
                FullScreenLoadingSpinner(isOverlay: false)
            } else {
                // The content view for all of the app
                ContentViewContainer().environmentObject(self.store)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(AppStore(initialState: AppState(), reducer: appReducer))
    }
}
