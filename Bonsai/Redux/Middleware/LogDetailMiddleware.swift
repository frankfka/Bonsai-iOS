//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct LogDetailMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
        ]
    }

//    private static func fetchLogDataMiddleware(logService: LogService) -> Middleware<AppState> {
//        return { state, action, cancellables, send in
//            switch action {
//            case .viewLog(action: .fetchData(let date)):
//                // Check user exists
//                guard let user = state.global.user else {
//                    fatalError("No user initialized when fetching logs")
//                }
//                fetchLogData(for: date, with: user, logService: logService)
//                        .sink(receiveValue: { newAction in
//                            send(newAction)
//                        })
//                        .store(in: &cancellables)
//            default:
//                break
//            }
//        }
//    }
//
//    // This just supports 1 day now
//    private static func fetchLogSearchable(with id: String, in category: LogCategory) -> AnyPublisher<AppAction, Never> {
//
//    }
}
