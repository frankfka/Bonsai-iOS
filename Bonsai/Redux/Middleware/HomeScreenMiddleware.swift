//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct HomeScreenMiddleware {

    static func middleware(services: AppServices) -> [Middleware<AppState>] {
        return [
            homeScreenDidShowMiddleware(),
            initHomeScreenMiddleware(logService: services.logService, logReminderService: services.logReminderService)
        ]
    }

    private static func homeScreenDidShowMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .homeScreen(action: .screenDidShow):
                if state.homeScreen.initSuccess {
                    // Do nothing else, already initialized - other middlewares should add to the state
                    return
                }
                // Send action to initialize data
                send(.homeScreen(action: .initializeData))
            default:
                break
            }
        }
    }

    private static func initHomeScreenMiddleware(logService: LogService, logReminderService: LogReminderService)
                    -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .homeScreen(action: .initializeData):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when initializing home screen data")
                }
                // Init recent log section
                initHomeScreen(logService: logService, logReminderService: logReminderService, for: user)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func initHomeScreen(logService: LogService, logReminderService: LogReminderService, for user: User)
                    -> AnyPublisher<AppAction, Never> {
        // Get recent logs
        let recentLogsPublisher = logService.getLogs(for: user, in: nil, since: nil, toAndIncluding: nil,
                        limitedTo: 20, startingAfterLog: nil, offline: false)
        // Get log reminders
        let logRemindersPublisher = logReminderService.getLogReminders()
        let combinedPublisher = Publishers.Zip(recentLogsPublisher, logRemindersPublisher)
        return combinedPublisher
                .map { recentLogs, logReminders in
                    return AppAction.homeScreen(action: .dataLoadSuccess(recentLogs: recentLogs, logReminders: logReminders))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.homeScreen(action: .dataLoadError(error: err)))
                }
                .eraseToAnyPublisher()
    }

}
