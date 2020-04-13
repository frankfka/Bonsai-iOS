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
    // TODO: this still tries to retrieve the last logs, figure out why
    private static func fetchAllLogDataMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .initAllLogData), .viewLog(action: .loadAdditionalLogs):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when fetching logs")
                }
                let fetchedLogs = state.globalLogs.sortedLogs
                let numToShow = state.viewLogs.viewAllNumToShow
                let (needToFetch, fetchAfterLogs) = needToFetchLogs(state: state)
                // Return immediately if we don't need to init
                if !needToFetch {
                    AppLogging.info("Enough logs already retrieved for all logs view, not retrieving")
                    send(AppAction.viewLog(action: .dataLoadSuccessForAllLogs(logs: Array(fetchedLogs.prefix(numToShow)), initialFetchLimit: numToShow)))
                    return
                }
                fetchLogData(totalLogsToShow: state.viewLogs.viewAllNumToShow, fetchAfterLogsInRevChronOrder: fetchAfterLogs, with: user, logService: logService)
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
            default: break
            }
        }
    }

    // Check whether we need to initialize new data
    // Returns true/false of whether we need to fetch additional logs
    // Returns a list of logs in reverse chronological order, indicating the logs to start retrieving after
    private static func needToFetchLogs(state: AppState) -> (Bool, [Loggable]) {
        let fetchedLogsInRevChronOrder = state.globalLogs.sortedLogs
        let numToShow = state.viewLogs.viewAllNumToShow
        var fetchAfterLogs: [Loggable] = []
        var needsInit = false
        let today = Date()
        if !state.globalLogs.retrievedAll {
            if fetchedLogsInRevChronOrder.count < numToShow {
                // Fetch if we don't have enough
                needsInit = true
            } else {
                // Check that all dates to the earliest log have been initialized
                let earliestLogDate = fetchedLogsInRevChronOrder[numToShow - 1].dateCreated
                if !state.globalLogs.hasBeenRetrieved(from: earliestLogDate, toAndIncluding: today) {
                    needsInit = true
                }
            }
        }
        /*
            If we need to initialize, we want to start at the latest log. This is unfortunately not as performant
            as I would like, but leaving this for now.

            A side effect is that if the earliest logs start on the earliest date, it is not marked as retrieved
            as we skip marking the earliest dates as fetched.
        */
        if needsInit {
            // Avoid checking the same date
            var checkedSet: Set<Date> = []
            for log in fetchedLogsInRevChronOrder {
                let needsChecking = !checkedSet.contains(log.dateCreated.beginningOfDate)
                if needsChecking &&
                           !state.globalLogs.hasBeenRetrieved(from: log.dateCreated, toAndIncluding: today) {
                    // Some dates have not been initialized, so start at the previous log
                    break
                }
                fetchAfterLogs.append(log)
                if needsChecking {
                    checkedSet.insert(log.dateCreated.beginningOfDate)
                }
            }
        }
        return (needsInit, fetchAfterLogs)
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
    private static func fetchLogData(totalLogsToShow: Int, fetchAfterLogsInRevChronOrder: [Loggable],
                                     with user: User, logService: LogService)  -> AnyPublisher<AppAction, Never> {
        let fetchLimit = totalLogsToShow - fetchAfterLogsInRevChronOrder.count
        print(fetchLimit)
        let startAfterLog = fetchAfterLogsInRevChronOrder.last
        return logService.getLogs(for: user, in: nil, since: nil, toAndIncluding: nil,
                        limitedTo: fetchLimit, startingAfterLog: startAfterLog, offline: false)
                .map { additionalLogs in
                    var allLogs = fetchAfterLogsInRevChronOrder
                    allLogs.append(contentsOf: additionalLogs)
                    return AppAction.viewLog(
                        action: .dataLoadSuccessForAllLogs(logs: Array(allLogs.prefix(totalLogsToShow)), initialFetchLimit: totalLogsToShow)
                    )
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
