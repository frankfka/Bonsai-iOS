//
//  HomeTab.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct HomeTab: View {
    @EnvironmentObject var store: AppStore
    
    init() {
        // TODO: Using unmonitored UIColor here
        UINavigationBar.appearance().backgroundColor = .secondarySystemGroupedBackground
    }
    
    var body: some View {
        NavigationView {
            // TODO: this scrollview goes under status bar
            ScrollView {
                VStack(alignment: .leading) {
                    HomeSectionWrapper(sectionView: AnyView(RecentLogSection()), sectionTitle: "Recent")
                }
                .padding(.all, CGFloat.Theme.Layout.normal)
            }
            .background(Color.Theme.backgroundPrimary)
            .navigationBarTitle("Home")
        }
    }
}

struct HomeTab_Previews: PreviewProvider {
    static var previews: some View {
        HomeTab().environmentObject(AppStore(initialState: AppState(), reducer: appReducer))
    }
}
