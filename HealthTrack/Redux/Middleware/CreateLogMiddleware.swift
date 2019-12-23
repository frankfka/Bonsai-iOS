//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Combine
import Foundation

func createLogSearchMiddleware(logService: LogService) -> Middleware<AppState> {
    return { state, action, cancellables, send in
        switch action {
        case let .createLog(action: .searchQueryDidChange(newQuery)):
            search(logService: logService, query: newQuery)
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
        default:
            break
        }
    }
}

private func search(logService: LogService, query: String) -> AnyPublisher<AppAction, Never> {
    return logService.search(with: query)
            .map { results in
                AppLogging.info("Query \(query) produced \(results.count) results")
                return AppAction.createLog(action: .searchResultsDidChange(results: results))
            }.catch { (err) -> Just<AppAction> in
                return Just(AppAction.createLog(action: .searchResultsDidChange(results: [])))
            }
            .eraseToAnyPublisher()
}
