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
            homeScreenInitMiddleware(logService: services.logService)
        ]
    }

    private static func homeScreenDidShowMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .homeScreen(action: .screenDidShow):
                if state.homeScreen.initSuccess {
                    // Do nothing, already initialized - other middlewares should add to the state
                    return
                }
                // Send action to initialize data
                doInMiddleware {
                    send(.homeScreen(action: .initializeData))
                }
            default:
                break
            }
        }
    }

    private static func homeScreenInitMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .homeScreen(action: .initializeData):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when searching")
                }
                initHomeScreen(logService: logService, for: user, in: nil, since: nil)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func initHomeScreen(logService: LogService, for user: User, in category: LogCategory?, since date: Date?) -> AnyPublisher<AppAction, Never> {
        return logService.get(for: user, in: category, since: date)
                .map { result in
                    return AppAction.homeScreen(action: .dataLoadSuccess(recentLogs: result))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.homeScreen(action: .dataLoadError(error: err)))
                }
                .eraseToAnyPublisher()
    }
}