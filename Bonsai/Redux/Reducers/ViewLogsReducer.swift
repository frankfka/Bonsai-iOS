//
// Created by Frank Jia on 2020-01-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

struct ViewLogsReducer {
    static func reduce(state: AppState, action: ViewLogsAction) -> AppState {
        switch action {
        case .screenDidShow:
            // Handled by middleware
            return state
        case let .dataLoadError(error):
            return dataLoadError(state: state, error: error)
        case let .viewTypeChanged(isViewByDate):
            return viewTypeChanged(state: state, isViewByDate: isViewByDate)
        // View by date
        case let .selectedDateChanged(date):
            return dateForLogsChanged(state: state, newDate: date)
        case .initDataByDate:
            return initAllLogData(state: state)
        case .dataInitSuccessForDate:
            return viewLogsByDateDataLoadSuccess(state: state)
        // View all
        case .initAllLogData:
            return initAllLogData(state: state)
        case let .dataLoadSuccessForAllLogs(allLogs):
            return viewAllLogsDataLoadSuccess(state: state, allLogs: allLogs)
        case let .numToShowChanged(newNumToShow):
            return numToShowChanged(state: state, newNumToShow: newNumToShow)
        case .loadAdditionalLogs:
            return loadAdditionalLogs(state: state)
        }
    }

    static private func initAllLogData(state: AppState) -> AppState {
        var newState = state
        newState.viewLogs.isLoading = true
        return newState
    }

    static private func dataLoadError(state: AppState, error: Error) -> AppState {
        var newState = state
        newState.viewLogs.isLoading = false
        newState.viewLogs.loadError = error
        return newState
    }

    static private func viewTypeChanged(state: AppState, isViewByDate: Bool) -> AppState {
        var newState = state
        newState.viewLogs.showLogsByDate = isViewByDate
        return newState
    }

    // MARK: View by date
    static private func dateForLogsChanged(state: AppState, newDate: Date) -> AppState {
        var newState = state
        newState.viewLogs.dateForLogs = newDate
        return newState
    }

    private static func viewLogsByDateDataLoadSuccess(state: AppState) -> AppState {
        var newState = state
        newState.viewLogs.isLoading = false
        newState.viewLogs.loadError = nil
        return newState
    }

    // MARK: View all
    static private func viewAllLogsDataLoadSuccess(state: AppState, allLogs: [Loggable]) -> AppState {
        var newState = state
        newState.viewLogs.isLoading = false
        newState.viewLogs.isLoadingMore = false
        newState.viewLogs.loadError = nil
        // If we load fewer than the number we're supposed to show, it means we've retrieved all the logs
        newState.viewLogs.canLoadMore = allLogs.count >= newState.viewLogs.viewAllNumToShow
        return newState
    }

    static private func numToShowChanged(state: AppState, newNumToShow: Int) -> AppState {
        var newState = state
        newState.viewLogs.viewAllNumToShow = newNumToShow
        return newState
    }
    
    static private func loadAdditionalLogs(state: AppState) -> AppState {
        var newState = state
        newState.viewLogs.isLoadingMore = true
        return newState
    }

}
