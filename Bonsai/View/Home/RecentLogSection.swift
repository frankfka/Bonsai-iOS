//
//  RecentLogSection.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct RecentLogSection: View {
    @EnvironmentObject var store: AppStore
    
    struct ViewModel {
        static let numToShow = 5  // Number of logs to show
        var showNoRecents: Bool {
            recentLogs.isEmpty
        }
        let recentLogs: [LogRow.ViewModel]
        @Binding var navigationState: HomeTab.NavigationState?

        init(recentLogs: [LogRow.ViewModel], navigateToLogDetails: Binding<HomeTab.NavigationState?>) {
            // Trim to specified length
            self.recentLogs = Array(recentLogs.prefix(ViewModel.numToShow))
            self._navigationState = navigateToLogDetails
        }

    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if self.viewModel.showNoRecents {
                NoRecentLogsView()
            } else {
                // Using the tag allows us to conditionally trigger navigation within an onTap method
                // This is useful because we can dispatch an action to initialize the redux state
                NavigationLink(destination: LogDetailView(), tag: HomeTab.NavigationState.logDetail, selection: viewModel.$navigationState) {
                    EmptyView()
                }
                ForEach(viewModel.recentLogs) { logVm in
                    Group {
                        LogRow(viewModel: logVm)
                            .onTapGesture {
                                self.onLogRowTapped(loggable: logVm.loggable)
                            }
                        if ViewHelpers.showDivider(after: logVm, in: self.viewModel.recentLogs) {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private func onLogRowTapped(loggable: Loggable) {
        store.send(.logDetails(action: .initState(loggable: loggable)))
        viewModel.navigationState = HomeTab.NavigationState.logDetail
    }
}

struct NoRecentLogsView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("No recent logs found")
                    .font(Font.Theme.heading)
                    .foregroundColor(Color.Theme.textDark)
            Text("Begin by adding a log using the \"+\" icon below")
                    .font(Font.Theme.normalText)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.Theme.text)
            Spacer()
        }
        .padding(CGFloat.Theme.Layout.normal)
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

struct RecentLogSection_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            RecentLogSection(
                    viewModel: RecentLogSection.ViewModel(
                            recentLogs: [
                                LogRow.ViewModel(loggable: PreviewLoggables.medication),
                                LogRow.ViewModel(loggable: PreviewLoggables.notes)
                            ],
                            navigateToLogDetails: .constant(nil)
                    )
            )
        }.previewLayout(.sizeThatFits)
    }
}
