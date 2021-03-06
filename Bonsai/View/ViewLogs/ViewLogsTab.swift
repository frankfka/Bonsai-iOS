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
        static let viewAllNumToShowIncrement = 10

        let isLoading: Bool
        let loadError: Bool
        let logViewModels: [LogRow.ViewModel]

        // View by date
        let showDatePicker: Bool
        let allowSwipeGesture: Bool
        let dateForLogs: Date

        // View all
        let showViewAllBottomActions: Bool

        init(state: AppState) {
            self.isLoading = state.viewLogs.isLoading
            self.loadError = state.viewLogs.loadError != nil
            self.dateForLogs = state.viewLogs.dateForLogs
            let showLogsByDate = state.viewLogs.showLogsByDate
            let logsToShow: [Loggable] // Show different logs depending on view type selection
            if showLogsByDate {
                // Show by date
                logsToShow = state.globalLogs.getLogs(for: dateForLogs)
            } else {
                // Show all
                logsToShow = Array(state.globalLogs.sortedLogs.prefix(state.viewLogs.viewAllNumToShow))
            }
            self.logViewModels = logsToShow.map { LogRow.ViewModel(loggable: $0) }
            self.showDatePicker = showLogsByDate
            self.allowSwipeGesture = showLogsByDate
            self.showViewAllBottomActions = !showLogsByDate
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

    private var viewModel: ViewModel { ViewModel(state: store.state) }
    // Child Vm's
    private var viewTypePickerViewVm: ViewLogsViewTypePickerView.ViewModel {
        ViewLogsViewTypePickerView.ViewModel(isViewByDate: self.store.state.viewLogs.showLogsByDate) {
            newIsViewByDate in
            self.store.send(.viewLog(action: .viewTypeChanged(isViewByDate: newIsViewByDate)))
        }
    }
    private var headerDatePickerViewVm: ViewLogsDateHeaderView.ViewModel {
        ViewLogsDateHeaderView.ViewModel(
            confirmedDate: store.state.viewLogs.dateForLogs,
            dateSelectionBinding: self.$datePickerSelection,
            onNewDateConfirmed: self.onNewDateConfirmed
        )
    }
    private var viewMoreLogsViewVm: ViewLogsLoadMoreView.ViewModel {
        let canLoadMore = store.state.viewLogs.canLoadMore
        let isLoadingMore = store.state.viewLogs.isLoadingMore
        let showLoadMoreButton = canLoadMore && !isLoadingMore
        let showLoadingMoreIndicator = isLoadingMore
        return ViewLogsLoadMoreView.ViewModel(
            showLoadingMoreIndicator: showLoadingMoreIndicator,
            showLoadMoreButton: showLoadMoreButton) {
            // Compute new number to show
            let newNumToShow = self.store.state.viewLogs.viewAllNumToShow + ViewModel.viewAllNumToShowIncrement
            self.store.send(.viewLog(action: .numToShowChanged(newNumToShow: newNumToShow)))
        }
    }

    @State(initialValue: false) private var navigateToLogDetails: Bool? // Allows conditional pushing of navigation views
    @State(initialValue: Date()) private var datePickerSelection: Date

    // MARK: Child Views
    private var viewTypeView: some View {
        ViewLogsViewTypePickerView(viewModel: self.viewTypePickerViewVm)
            .padding(.vertical, CGFloat.Theme.Layout.Small)
            .padding(.horizontal, CGFloat.Theme.Layout.Normal)
            .background(Color.Theme.BackgroundSecondary)
    }
    private var datePickerHeaderView: some View {
        ViewLogsDateHeaderView(viewModel: self.headerDatePickerViewVm)
    }
    private var mainScrollView: some View {
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
                if viewModel.showViewAllBottomActions {
                    ViewLogsLoadMoreView(viewModel: self.viewMoreLogsViewVm)
                }
            }
            .modifier(RoundedBorderSectionModifier())
            .padding(.all, CGFloat.Theme.Layout.Normal)
        }
        .modifier(ViewLogsTabSwipeGestureRecognizer(onSwipe: self.onLogSectionSwipe))
    }

    // MARK: Main View
    var body: some View {
        VStack(spacing: 0) {
            // Header section
            self.viewTypeView
            if self.viewModel.showDatePicker {
                self.datePickerHeaderView
            }
            // Main body
            if viewModel.isLoading {
                FullScreenLoadingSpinner(isOverlay: false)
            } else if viewModel.loadError {
                FullScreenErrorView()
            } else if viewModel.logViewModels.isEmpty {
                ViewLogsTabNoResultsView()
            } else {
                self.mainScrollView
            }
        }
        // Use flex frame so it always fills width
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
        .onAppear {
            self.onAppear()
        }
        .background(Color.Theme.BackgroundPrimary)
        .navigationBarTitle("Logs")
        .embedInNavigationView()
    }

    // MARK: Actions
    private func onAppear() {
        self.navigateToLogDetails = nil // Resets navigation state
        self.store.send(.viewLog(action: .screenDidShow))
    }

    private func onLogRowTapped(loggable: Loggable) {
        store.send(.logDetails(action: .initState(loggable: loggable)))
        navigateToLogDetails = true
    }

    private func onNewDateConfirmed(_ date: Date) {
        self.datePickerSelection = date
        self.store.send(.viewLog(action: .selectedDateChanged(date: date)))
    }

    private func onLogSectionSwipe(direction: ViewLogsTabSwipeGestureRecognizer.Direction) {
        guard self.viewModel.allowSwipeGesture else {
            // Not choosing logs by date, so ignore swipes
            return
        }
        // Left swipe is to increase date
        let newDate = self.viewModel.dateForLogs.addingTimeInterval(direction == .left ? TimeInterval.day : -TimeInterval.day)
        guard newDate <= Date() else {
            // Trying to go past today, ignore
            return
        }
        self.onNewDateConfirmed(newDate)
    }

}

