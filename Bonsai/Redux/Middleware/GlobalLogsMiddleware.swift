//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct GlobalLogsMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            mapActionsToGlobalLogActionMiddleware(),
            mapActionsToUpdateAnalyticsMiddleware(),
            updateAnalyticsMiddleware(analyticsService: services.analyticsService)
        ]
    }

    // MARK: Middleware to map individual screen actions to global log actions
    private static func mapActionsToGlobalLogActionMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            // Home Screen
            case .homeScreen(action: let .dataLoadSuccess(recentLogs, _)):
                send(.globalLog(action: .insert(logs: recentLogs)))
                send(.globalLog(action: .markAsRetrieved(dates: getMarkAsRetrievedDates(for: recentLogs, upToToday: true))))
            // Create Log
            case .createLog(action: let .onSaveSuccess(newLog, _)):
                send(.globalLog(action: .insert(logs: [newLog])))
            // View Logs
            case .viewLog(action: let .dataInitSuccessForDate(logs, date)):
                send(.globalLog(action: .replace(logs: logs, date: date)))
                send(.globalLog(action: .markAsRetrieved(dates: [date])))
            case .viewLog(action: let .dataLoadSuccessForAllLogs(logs, initialFetchLimit)):
                send(.globalLog(action: .insert(logs: logs)))
                send(.globalLog(action: .markAsRetrieved(dates: getMarkAsRetrievedDates(for: logs))))
                // If we fetched all, but got less than the limit back, it means we've fetched all available
                if logs.count < initialFetchLimit {
                    send(.globalLog(action: .markAllAsRetrieved))
                }
            // View Log Detail
            case .logDetails(action: let .deleteSuccess(deletedLog)):
                send(.globalLog(action: .delete(log: deletedLog)))
            default:
                break
            }
        }
    }

    // UpToToday indicates that we've tried fetching for all logs up to the current date
    private static func getMarkAsRetrievedDates(for retrievedLogs: [Loggable], upToToday: Bool = false) -> [Date] {
        if retrievedLogs.count == 0 {
            return []
        }
        // Reverse chronological
        let allLogs = retrievedLogs.sorted { first, second in first.dateCreated > second.dateCreated }
        let mostRecentDate = upToToday ? Date() : allLogs[0].dateCreated
        let earliestDate = allLogs[allLogs.count - 1].dateCreated
        // We can't be certain that all logs for the earliest date were retrieved, so need to add a day
        var markAsRetrievedDate = earliestDate.addingTimeInterval(.day).beginningOfDate
        var dates: [Date] = []
        while markAsRetrievedDate < mostRecentDate {
            // Mark all the dates from the earliest to the most recent as retrieved
            dates.append(markAsRetrievedDate)
            markAsRetrievedDate = markAsRetrievedDate.addingTimeInterval(.day)
        }
        return dates
    }

    // MARK: Analytics
    private static func mapActionsToUpdateAnalyticsMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .globalLog(action: .insert):
                send(.globalLog(action: .updateAnalytics))
            case .globalLog(action: .delete):
                send(.globalLog(action: .updateAnalytics))
            case .settings(action: .saveSettingsSuccess):
                send(.globalLog(action: .updateAnalytics))
            default:
                break
            }
        }
    }

    private static func updateAnalyticsMiddleware(analyticsService: AnalyticsService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .globalLog(action: .updateAnalytics):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when initializing analytics")
                }
                // TODO: have this cancel any in-flight operations?
                updateAnalytics(analyticsService: analyticsService, for: user)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func updateAnalytics(analyticsService: AnalyticsService, for user: User) -> AnyPublisher<AppAction, Never> {
        return analyticsService.getAllAnalytics(for: user).map { result in
            return AppAction.globalLog(action: .analyticsLoadSuccess(analytics: result))
        }.catch { (err) -> Just<AppAction> in
            return Just(AppAction.globalLog(action: .analyticsLoadError(error: err)))
        }.eraseToAnyPublisher()
    }

}
