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
            // Check user exists
            guard let user = state.global.user else {
                fatalError("No user initialized when searching")
            }
            // Check query is not empty
            if newQuery.isEmptyWithoutWhitespace() {
                return
            }
            // Perform search
            search(logService: logService, with: newQuery, for: user)
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
        default:
            break
        }
    }
}

private func search(logService: LogService, with query: String, for user: User) -> AnyPublisher<AppAction, Never> {
    return logService.search(with: query, by: user)
            .map { results in
                return AppAction.createLog(action: .searchResultsDidChange(results: results))
            }.catch { (err) -> Just<AppAction> in
                return Just(AppAction.createLog(action: .searchResultsDidChange(results: [])))
            }
            .eraseToAnyPublisher()
}
