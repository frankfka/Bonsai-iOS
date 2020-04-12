//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

extension Date {

    // TODO: Force unwrap here
    var beginningOfDate: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    var endOfDate: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self.addingTimeInterval(TimeInterval.day))!
    }

    func isInDay(_ date: Date) -> Bool {
        return self < date.endOfDate && self >= date.beginningOfDate
    }
}

struct ViewLogsMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            mapOnAppearToFetchDataActionMiddleware(),
            mapViewTypeChangeToFetchDataActionMiddleware(),
            mapDateChangeToFetchDataActionMiddleware(),
            mapViewAllNumToShowChangeToLoadDataActionMiddleware(),
            fetchAdditionalLogsMiddleware(logService: services.logService),
            fetchAllLogDataMiddleware(logService: services.logService),
            fetchLogDataForDateMiddleware(logService: services.logService)
        ]
    }

    // Maps onAppear to the correct retrieval action
    private static func mapOnAppearToFetchDataActionMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .screenDidShow):
                send(getFetchDataAction(isViewByDate: state.viewLogs.showLogsByDate, state: state))
            default:
                break
            }
        }
    }

    // Maps a view type change to the relevant fetch action
    private static func mapViewTypeChangeToFetchDataActionMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .viewTypeChanged(let isViewByDate)):
                send(getFetchDataAction(isViewByDate: isViewByDate, state: state))
            default:
                break
            }
        }
    }

    private static func getFetchDataAction(isViewByDate: Bool, state: AppState) -> AppAction {
        if isViewByDate {
            return .viewLog(action: .initDataByDate(date: state.viewLogs.dateForLogs))
        } else {
            return .viewLog(action: .initAllLogData)
        }
    }

    // Maps a date change to a fetch data action
    private static func mapDateChangeToFetchDataActionMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .selectedDateChanged(let date)):
                send(.viewLog(action: .initDataByDate(date: date)))
            default:
                break
            }
        }
    }

    // Maps a request to load more logs to a fetch data action
    private static func mapViewAllNumToShowChangeToLoadDataActionMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .numToShowChanged):
                send(.viewLog(action: .loadAdditionalLogs))
            default:
                break
            }
        }
    }

    // Called when we want to fetch all logs
    // TODO: need to consolidate these two
    // TODO: fetch only logs after our last log?
    // TODO: this will always cause loading if we're past the total # of logs for the user
    private static func fetchAdditionalLogsMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .loadAdditionalLogs):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when fetching logs")
                }
                let fetchedLogs = state.globalLogs.sortedLogs
                let numToShow = state.viewLogs.viewAllNumToShow
                // Return immediately if we don't need to init
                if !needToFetchLogs(state: state) {
                    AppLogging.info("Enough logs already retrieved for all logs view, not retrieving")
                    send(AppAction.viewLog(action: .dataLoadSuccessForAllLogs(logs: Array(fetchedLogs.prefix(numToShow)))))
                    return
                }
                fetchLogData(fetchLimit: state.viewLogs.viewAllNumToShow, with: user, logService: logService)
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
            default:
                break
            }
        }
    }
    private static func fetchAllLogDataMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .initAllLogData):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when fetching logs")
                }
                let fetchedLogs = state.globalLogs.sortedLogs
                let numToShow = state.viewLogs.viewAllNumToShow
                // Return immediately if we don't need to init
                if !needToFetchLogs(state: state) {
                    AppLogging.info("Enough logs already retrieved for all logs view, not retrieving")
                    send(AppAction.viewLog(action: .dataLoadSuccessForAllLogs(logs: Array(fetchedLogs.prefix(numToShow)))))
                    return
                }
                fetchLogData(fetchLimit: state.viewLogs.viewAllNumToShow, with: user, logService: logService)
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
            default: break
            }
        }
    }

    // Check whether we need to initialize new data
    private static func needToFetchLogs(state: AppState) -> Bool {
        let fetchedLogs = state.globalLogs.sortedLogs
        let numToShow = state.viewLogs.viewAllNumToShow
        var needsInit = false
        if fetchedLogs.count < numToShow {
            // Fetch if we don't have enough
            needsInit = true
        } else {
            // Check that all dates to the earliest log have been initialized
            let earliestLogDate = fetchedLogs[numToShow - 1].dateCreated
            if !state.globalLogs.hasBeenRetrieved(from: earliestLogDate, toAndIncluding: Date()) {
                needsInit = true
            }
        }
        return needsInit
    }

    // Called when we want to fetch data for a specific date (By Date view)
    private static func fetchLogDataForDateMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .initDataByDate(let date)):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when fetching logs")
                }
                // Don't fetch if we have already initialized
                let isInitialized = state.globalLogs.hasBeenRetrieved(date)
                let logsForDate = state.globalLogs.getLogs(for: date)
                if isInitialized {
                    // TODO: Consider a separate action - this will trigger global logs middleware
                    AppLogging.info("Logs already exist for this date, not retrieving from service")
                    send(AppAction.viewLog(action: .dataInitSuccessForDate(logs: logsForDate, date: date)))
                    return
                }
                fetchLogData(for: date, with: user, logService: logService)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    // Used for all logs view
    private static func fetchLogData(fetchLimit: Int, with user: User, logService: LogService)  -> AnyPublisher<AppAction, Never> {
        logService.getLogs(for: user, in: nil, since: nil, toAndIncluding: nil,
                        limitedTo: fetchLimit, startingAfterLog: nil, offline: false)
                .map { logData in
                    return AppAction.viewLog(action: .dataLoadSuccessForAllLogs(logs: logData))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.viewLog(action: .dataLoadError(error: err)))
                }
                .eraseToAnyPublisher()
    }

    // Used for date view
    private static func fetchLogData(for date: Date, with user: User, logService: LogService) -> AnyPublisher<AppAction, Never> {
        logService.getLogs(for: user, in: nil, since: date.beginningOfDate, toAndIncluding: date.endOfDate,
                        limitedTo: nil, startingAfterLog: nil, offline: false)
                .map { logData in
                    return AppAction.viewLog(action: .dataInitSuccessForDate(logs: logData, date: date))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.viewLog(action: .dataLoadError(error: err)))
                }
                .eraseToAnyPublisher()
    }
}
