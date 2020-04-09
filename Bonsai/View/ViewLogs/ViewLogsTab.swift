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
        let dateForLogs: Date
        let logViewModels: [LogRow.ViewModel]

        init(isLoading: Bool, loadError: Bool, dateForLogs: Date, logViewModels: [LogRow.ViewModel]) {
            self.isLoading = isLoading
            self.loadError = loadError
            self.dateForLogs = dateForLogs
            self.logViewModels = logViewModels
        }

        func showDivider(after vm: LogRow.ViewModel) -> Bool {
            let index = logViewModels.firstIndex { item in
                vm.id == item.id
            }
            if let index = index, index < logViewModels.count - 1 {
                return true
            }
            return false
        }
    }

    private var viewModel: ViewModel {
        getViewModel()
    }
    @State(initialValue: false) private var navigateToLogDetails: Bool? // Allows conditional pushing of navigation views

    var body: some View {
        VStack(spacing: 0) {
            ViewLogsViewTypePickerView(viewModel: getViewTypePickerViewModel())
            ViewLogsDateHeaderView(viewModel: getHeaderDatePickerViewModel())
            if viewModel.isLoading {
                FullScreenLoadingSpinner(isOverlay: false)
            } else if viewModel.loadError {
                ErrorView()
            } else if viewModel.logViewModels.isEmpty {
                ViewLogsTabNoResultsView()
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        // Using the tag allows us to conditionally trigger navigation within an onTap method
                        NavigationLink(destination: LogDetailView(), tag: true, selection: $navigateToLogDetails) {
                            EmptyView()
                        }
                        ForEach(viewModel.logViewModels) { logVm in
                            Group {
                                LogRow(viewModel: logVm)
                                        .onTapGesture {
                                            self.onLogRowTapped(loggable: logVm.loggable)
                                        }
                                if self.viewModel.showDivider(after: logVm) {
                                    Divider()
                                }
                            }
                        }
                    }
                    .modifier(RoundedBorderSectionModifier())
                    .padding(.all, CGFloat.Theme.Layout.normal)
                }
            }
        }
        // Use flex frame so it always fills width
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
        .onAppear {
            self.onAppear()
        }
        .background(Color.Theme.backgroundPrimary)
        .navigationBarTitle("Logs")
        .embedInNavigationView()
        .padding(.top) // Temporary - bug where scrollview goes under the status bar
    }

    private func getViewModel() -> ViewModel {
        let dateForLogs = store.state.viewLogs.dateForLogs
        let logsForDate = store.state.globalLogs.getLogs(for: dateForLogs)
        return ViewLogsTabContainer.ViewModel(
                isLoading: store.state.viewLogs.isLoading,
                loadError: store.state.viewLogs.loadError != nil,
                dateForLogs: dateForLogs,
                logViewModels: logsForDate.map {
                    LogRow.ViewModel(loggable: $0)
                }
        )
    }

    private func onAppear() {
        self.navigateToLogDetails = nil // Resets navigation state
        self.store.send(.viewLog(action: .fetchData(date: self.store.state.viewLogs.dateForLogs)))
    }

    private func getViewTypePickerViewModel() -> ViewLogsViewTypePickerView.ViewModel {
        return ViewLogsViewTypePickerView.ViewModel(isViewByDate: self.store.state.viewLogs.showLogsByDate) {
            newIsViewByDate in
            self.store.send(.viewLog(action: .viewTypeChanged(isViewByDate: newIsViewByDate)))
        }
    }

    private func getHeaderDatePickerViewModel() -> ViewLogsDateHeaderView.ViewModel {
        return ViewLogsDateHeaderView.ViewModel(
                initialDate: store.state.viewLogs.dateForLogs
        ) { newDate in
            self.store.send(.viewLog(action: .selectedDateChanged(date: newDate)))
            self.store.send(.viewLog(action: .fetchData(date: newDate)))
        }
    }

    private func onLogRowTapped(loggable: Loggable) {
        store.send(.logDetails(action: .initState(loggable: loggable)))
        navigateToLogDetails = true
    }

}

// Segmented picker at the top to select between "By Date" and "All" view types
struct ViewLogsViewTypePickerView: View {

    struct ViewModel {
        static let displayValues: [String] = ["By Date", "All"]
        @Binding var pickerSelection: Int

        init(isViewByDate: Bool, onNewViewByDateChangedValue: BoolCallback? = nil) {
            self._pickerSelection = Binding<Int>(get: {
                isViewByDate ? 0 : 1
            }, set: { newVal in
                onNewViewByDateChangedValue?(newVal == 0)
            })
        }
    }

    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            // TODO: Unfortunately we get weird flickering behavior on re-rendering, leaving for now
            Picker("", selection: self.viewModel.$pickerSelection) {
                ForEach(0..<ViewModel.displayValues.count) { index in
                    Text(ViewModel.displayValues[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.vertical, CGFloat.Theme.Layout.small)
        .padding(.horizontal, CGFloat.Theme.Layout.normal)
        .background(Color.Theme.backgroundSecondary)
    }
}

// Text to show no results
struct ViewLogsTabNoResultsView: View {

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("No Logs Found")
                    .font(Font.Theme.heading)
                    .foregroundColor(Color.Theme.textDark)
            Spacer()
        }.frame(minWidth: 0, maxWidth: .infinity)
    }

}
