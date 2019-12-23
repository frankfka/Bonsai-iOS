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
    var body: some View {
        ZStack {
            ContentViewContainer().environmentObject(self.store)
            if store.state.global.isInitializing {
                FullScreenLoadingSpinner()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(AppStore(initialState: AppState(), reducer: appReducer))
    }
}
