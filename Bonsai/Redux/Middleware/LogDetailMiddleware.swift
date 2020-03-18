//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct LogDetailMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            initLogData(logService: services.logService),
            deleteLog(logService: services.logService)
        ]
    }

    private static func initLogData(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .logDetails(action: .initState(let initialLoggable)):
                initLogData(for: initialLoggable, logService: logService)
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func initLogData(for loggable: Loggable, logService: LogService) -> AnyPublisher<AppAction, Never> {
        return logService.initLogDetails(for: loggable).map { initializedLoggable -> AppAction in
            AppAction.logDetails(action: .fetchLogDataSuccess(loggable: initializedLoggable))
        }.catch { err -> Just<AppAction> in
            Just(AppAction.logDetails(action: .fetchLogDataError(error: err)))
        }.eraseToAnyPublisher()
    }

    private static func deleteLog(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .logDetails(action: .deleteCurrentLog):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when attempting to delete a log")
                }
                guard let log = state.logDetails.loggable else {
                    send(.logDetails(action: .deleteError(error: ServiceError(message: "No loggable initialized in log details state, so cannot delete the log"))))
                    return
                }
                deleteLog(_ : log, for: user, logService: logService)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func deleteLog(_ log: Loggable, for user: User, logService: LogService) -> AnyPublisher<AppAction, Never> {
        return logService.deleteLog(with: log.id, for: user)
                .map {
                    AppLogging.info("Success deleting log \(log.id) for user \(user.id)")
                    return AppAction.logDetails(action: .deleteSuccess(deletedLog: log))
                }.catch({ (err) -> Just<AppAction> in
                    AppLogging.info("Failed to delete log \(log.id) for user \(user.id): \(err)")
                    return Just(AppAction.logDetails(action: .deleteError(error: err)))
                }).eraseToAnyPublisher()
    }

}
