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
            // Perform search
            search(logService: logService, with: newQuery, for: user, in: state.createLog.selectedCategory)
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
        default:
            break
        }
    }
}

private func search(logService: LogService, with query: String, for user: User, in category: LogCategory) -> AnyPublisher<AppAction, Never> {
    if query.isEmptyWithoutWhitespace() {
        // Don't perform a query, just return empty results
        return Just(AppAction.createLog(action: .searchDidComplete(results: []))).eraseToAnyPublisher()
    }
    return logService.search(with: query, by: user, in: category)
            .map { results in
                return AppAction.createLog(action: .searchDidComplete(results: results))
            }.catch { (err) -> Just<AppAction> in
                return Just(AppAction.createLog(action: .searchDidComplete(results: [])))
            }
            .eraseToAnyPublisher()
}
