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
        static let numToShowIncrement = 5  // Number of logs to show
        var showNoRecents: Bool {
            recentLogs.isEmpty
        }
        let recentLogs: [LogRow.ViewModel]
        @Binding var navigationState: HomeTab.NavigationState?

        init(recentLogs: [Loggable], navigationState: Binding<HomeTab.NavigationState?>) {
            self.recentLogs = recentLogs.map { LogRow.ViewModel(loggable: $0) }
            self._navigationState = navigationState
        }

        // Get view model for the bottom button that displays "Show More/Less"
        func getBottomButtonViewModel(currentDisplayNum: Binding<Int>) -> BottomButtonViewModel {
            if currentDisplayNum.wrappedValue > ViewModel.numToShowIncrement {
                // Display show less
                return BottomButtonViewModel(disabled: false, text: "Show Less", onTap: {
                    currentDisplayNum.wrappedValue = currentDisplayNum.wrappedValue - ViewModel.numToShowIncrement
                })
            } else {
                // Display show more
                let isDisabled = recentLogs.count <= currentDisplayNum.wrappedValue
                return BottomButtonViewModel(disabled: isDisabled, text: "Show More", onTap: {
                    currentDisplayNum.wrappedValue = currentDisplayNum.wrappedValue + ViewModel.numToShowIncrement
                })
            }
        }

        struct BottomButtonViewModel {
            let disabled: Bool
            let text: String
            let onTap: VoidCallback?
        }
    }
    private let viewModel: ViewModel
    private var bottomButtonViewModel: ViewModel.BottomButtonViewModel {
        viewModel.getBottomButtonViewModel(currentDisplayNum: $numToShow)
    }
    @State(initialValue: ViewModel.numToShowIncrement) private var numToShow: Int

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .center) {
            if self.viewModel.showNoRecents {
                NoRecentLogsView()
            } else {
                // Using the tag allows us to conditionally trigger navigation within an onTap method
                // This is useful because we can dispatch an action to initialize the redux state
                NavigationLink(destination: LogDetailView(), tag: HomeTab.NavigationState.logDetail, selection: viewModel.$navigationState) {
                    EmptyView()
                }
                ForEach(viewModel.recentLogs.prefix(numToShow)) { logVm in
                    Group {
                        LogRow(viewModel: logVm)
                            .onTapGesture {
                                self.onLogRowTapped(loggable: logVm.loggable)
                            }
                        if ViewHelpers.showDivider(after: logVm, in: self.viewModel.recentLogs, withDisplayLimit: self.numToShow) {
                            Divider()
                        }
                    }
                }
                Button(action: {
                    self.bottomButtonViewModel.onTap?()
                }, label: {
                    Text(self.bottomButtonViewModel.text)
                        .font(Font.Theme.normalText)
                        .foregroundColor(self.bottomButtonViewModel.disabled ?
                                Color.Theme.grayscalePrimary : Color.Theme.primary)
                        .padding(CGFloat.Theme.Layout.small)
                })
                .disabled(self.bottomButtonViewModel.disabled)
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
                                PreviewLoggables.medication,
                                PreviewLoggables.notes
                            ],
                            navigationState: .constant(nil)
                    )
            )
        }.previewLayout(.sizeThatFits)
    }
}
