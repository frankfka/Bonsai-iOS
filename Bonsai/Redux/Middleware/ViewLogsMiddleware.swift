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
            fetchLogDataMiddleware(logService: services.logService)
        ]
    }

    private static func fetchLogDataMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .viewLog(action: .fetchData(let date)):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when fetching logs")
                }
                // Don't fetch if we already have data
                let logsForDate = state.viewLogs.logsForDate(date)
                guard logsForDate.isEmpty else {
                    AppLogging.info("Logs already exist for this date, not retrieving from service")
                    send(AppAction.viewLog(action: .dataLoadSuccess(logs: logsForDate)))
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
        logService.getLogs(for: user, in: nil, since: date.beginningOfDate, toAndIncluding: date.endOfDate, limitedTo: nil, offline: false)
                .map { logData in
                    return AppAction.viewLog(action: .dataLoadSuccess(logs: logData))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.viewLog(action: .dataLoadError(error: err)))
                }
                .eraseToAnyPublisher()
    }
}
