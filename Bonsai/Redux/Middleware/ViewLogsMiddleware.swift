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
            mapViewTypeChangeToFetchDataActionMiddleware(),
            mapDateChangeToFetchDataActionMiddleware(),
            fetchAllLogDataMiddleware(logService: services.logService),
            fetchLogDataForDateMiddleware(logService: services.logService)
        ]
    }

    // Maps a view type change to the relevant fetch action
    private static func mapViewTypeChangeToFetchDataActionMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .viewTypeChanged(let isViewByDate)):
                if isViewByDate {
                    // Change to view by date
                    send(.viewLog(action: .fetchDataByDate(date: state.viewLogs.dateForLogs)))
                } else {
                    // Change to view all
                    send(.viewLog(action: .fetchAllLogData(limit: state.viewLogs.viewAllNumToShow)))
                }
            default:
                break
            }
        }
    }

    // Maps a date change to a fetch data action
    private static func mapDateChangeToFetchDataActionMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .selectedDateChanged(let date)):
                send(.viewLog(action: .fetchDataByDate(date: date)))
            default:
                break
            }
        }
    }

    // Called when we want to fetch all logs
    private static func fetchAllLogDataMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .fetchAllLogData(let limit)):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when fetching logs")
                }
                // Check whether we need to initialize new data
                let fetchedLogs = state.globalLogs.sortedLogs
                let numToShow = state.viewLogs.viewAllNumToShow
                var needsInit = false
                if fetchedLogs.count < numToShow {
                    // Fetch if we don't have enough
                    needsInit = true
                } else {
                    // TODO: can have home screen init action make all of the dates its fetched marked on global log?
                    // Check that all dates to the earliest log have been initialized
                    let earliestLogDate = fetchedLogs[numToShow - 1].dateCreated
                    var checkDate = Date()
                    while checkDate > earliestLogDate {
                        if !state.globalLogs.hasBeenRetrieved(checkDate) {
                            needsInit = true
                            break
                        }
                        checkDate = checkDate.addingTimeInterval(-TimeInterval.day)
                    }
                }
                // Return immediately if we don't need to init
                if !needsInit {
                    AppLogging.info("Enough logs already retrieved for all logs view, not retrieving")
                    send(AppAction.viewLog(action: .dataLoadSuccessForAllLogs(logs: Array(fetchedLogs.prefix(numToShow)))))
                    return
                }
                // TODO: Fetch more
            default: break
            }
        }
    }

    // Called when we want to fetch data for a specific date (By Date view)
    private static func fetchLogDataForDateMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .fetchDataByDate(let date)):
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
                    send(AppAction.viewLog(action: .dataLoadSuccessForDate(logs: logsForDate, date: date)))
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

    // This just supports 1 day now
    private static func fetchLogData(for date: Date, with user: User, logService: LogService) -> AnyPublisher<AppAction, Never> {
        logService.getLogs(for: user, in: nil, since: date.beginningOfDate, toAndIncluding: date.endOfDate,
                        limitedTo: nil, startingAfterLog: nil, offline: false)
                .map { logData in
                    return AppAction.viewLog(action: .dataLoadSuccessForDate(logs: logData, date: date))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.viewLog(action: .dataLoadError(error: err)))
                }
                .eraseToAnyPublisher()
    }
}
