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
            mapLogActionsToUpdateAnalyticsMiddleware(),
            updateAnalyticsMiddleware(analyticsService: services.analyticsService)
        ]
    }

    // MARK: Middleware to map individual screen actions to global log actions
    private static func mapActionsToGlobalLogActionMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            // Home Screen
            case .homeScreen(action: let .dataLoadSuccess(recentLogs)):
                send(.globalLog(action: .insertMany(logs: recentLogs)))
            // Create Log
            case .createLog(action: let .onSaveSuccess(newLog)):
                send(.globalLog(action: .insert(log: newLog)))
            // View Logs
            case .viewLog(action: let .dataLoadSuccess(logs, date)):
                send(.globalLog(action: .replace(logs: logs, date: date)))
                send(.globalLog(action: .markAsRetrieved(date: date)))
            // View Log Detail
            case .logDetails(action: let .deleteSuccess(deletedLog)):
                send(.globalLog(action: .delete(log: deletedLog)))
            default:
                break
            }
        }
    }

    // MARK: Analytics
    private static func mapLogActionsToUpdateAnalyticsMiddleware() -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .globalLog(action: .insert):
                send(.globalLog(action: .updateAnalytics))
            case .globalLog(action: .insertMany):
                send(.globalLog(action: .updateAnalytics))
            case .globalLog(action: .delete):
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