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
        case .fetchDataByDate:
            return fetchData(state: state)
        case .dataLoadSuccessForDate:
            return dataLoadSuccess(state: state)
        // View all
        case .fetchAllLogData:
            return fetchData(state: state)
        case .dataLoadSuccessForAllLogs:
            return dataLoadSuccess(state: state)
        }
    }

    static private func fetchData(state: AppState) -> AppState {
        var newState = state
        newState.viewLogs.isLoading = true
        return newState
    }

    static private func dataLoadSuccess(state: AppState) -> AppState {
        var newState = state
        newState.viewLogs.isLoading = false
        newState.viewLogs.loadError = nil
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
}
