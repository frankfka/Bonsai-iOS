//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct HomeScreenMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            homeScreenDidShowMiddleware(),
            initDataMiddleware(logService: services.logService),
            initAnalyticsMiddleware(analyticsService: services.analyticsService)
        ]
    }

    private static func homeScreenDidShowMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .homeScreen(action: .screenDidShow):
                // Init analytics
                // TODO: We do this every time we show home screen, is there another way around it?
                send(.homeScreen(action: .initializeAnalytics))
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

    private static func initDataMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .homeScreen(action: .initializeData):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when searching")
                }
                // Init recent log section
                initRecentLogs(logService: logService, for: user, in: nil, since: nil, toAndIncluding: nil)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func initRecentLogs(logService: LogService, for user: User, in category: LogCategory?,
                                       since beginDate: Date?, toAndIncluding endDate: Date?) -> AnyPublisher<AppAction, Never> {
        return logService.getLogs(for: user, in: category, since: beginDate,
                        toAndIncluding: endDate, limitedTo: RecentLogSection.ViewModel.numToShow)
                .map { result in
                    return AppAction.homeScreen(action: .dataLoadSuccess(recentLogs: result))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.homeScreen(action: .dataLoadError(error: err)))
                }
                .eraseToAnyPublisher()
    }

    private static func initAnalyticsMiddleware(analyticsService: AnalyticsService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .homeScreen(action: .initializeAnalytics):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when searching")
                }
                // Init recent log section
                initAnalytics(analyticsService: analyticsService, for: user)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func initAnalytics(analyticsService: AnalyticsService, for user: User) -> AnyPublisher<AppAction, Never> {
        return analyticsService.getAllAnalytics(for: user).map { result in
            return AppAction.homeScreen(action: .analyticsLoadSuccess(analytics: result))
        }.catch { (err) -> Just<AppAction> in
            return Just(AppAction.homeScreen(action: .analyticsLoadError(error: err)))
        }.eraseToAnyPublisher()
    }

}
