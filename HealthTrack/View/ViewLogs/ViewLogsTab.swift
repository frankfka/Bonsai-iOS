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
        let dateForLogs: Date
        let logs: [LogRow.ViewModel]
        
        func showDivider(after vm: LogRow.ViewModel) -> Bool {
            let index = logs.firstIndex { item in vm.id == item.id }
            if let index = index, index < logs.count - 1 {
                return true
            }
            return false
        }
    }
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        // TODO: Using unmonitored UIColor here
        UINavigationBar.appearance().backgroundColor = .secondarySystemGroupedBackground
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ViewLogsDateHeaderView(viewModel: getHeaderDatePickerViewModel())
            if viewModel.isLoading {
                FullScreenLoadingSpinner(isOverlay: false)
            } else if viewModel.loadError {
                ErrorView()
            } else if viewModel.logs.isEmpty {
                ViewLogsTabNoResultsView()
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.logs) { log in
                            Group {
                                LogRow(viewModel: log)
                                if self.viewModel.showDivider(after: log) {
                                    Divider()
                                }
                            }
                        }
                    }.modifier(RoundedBorderSection())
                }
                .padding(.all, CGFloat.Theme.Layout.normal)
            }
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
    
    private func getHeaderDatePickerViewModel() -> ViewLogsDateHeaderView.ViewModel {
        return ViewLogsDateHeaderView.ViewModel(
            initialDate: store.state.viewLogs.dateForLogs
        ) { newDate in
            self.store.send(.viewLog(action: .selectedDateChanged(date: newDate)))
            self.store.send(.viewLog(action: .fetchData(date: newDate)))
        }
    }
}

struct ViewLogsTabNoResultsView: View {

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("No Logs Found")
                .font(Font.Theme.heading)
                    .foregroundColor(Color.Theme.textDark)
            // TODO: "Or show most recent"
            Text("Try searching for other dates.")
            .font(Font.Theme.normalText)
            .foregroundColor(Color.Theme.text)
            Spacer()
        }
    }

}
