//
//  HomeTab.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct ViewLogsTabContainer: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        let isLoading: Bool
        let loadError: Bool
        let viewLogsTabDidAppear: VoidCallback?
    }

    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        // TODO: Using unmonitored UIColor here
        UINavigationBar.appearance().backgroundColor = .secondarySystemGroupedBackground
    }

    var body: some View {

        ScrollView {
            VStack(alignment: .leading) {
                Text("Testing")
            }
            .padding(.all, CGFloat.Theme.Layout.normal)
        }
        // Use flex frame so it always fills width
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
        .onAppear {
            self.viewModel.viewLogsTabDidAppear?()
        }
        .background(Color.Theme.backgroundPrimary)
        .navigationBarTitle("Logs")
        .embedInNavigationView()
        .padding(.top) // Temporary - bug where scrollview goes under the status bar
    }
}