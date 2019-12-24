//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

typealias ServiceCallback<SuccessType> = (Result<SuccessType, ServiceError>) -> ()
typealias ServicePublisher<SuccessType> = AnyPublisher<SuccessType, ServiceError>
typealias ServiceFuture<SuccessType> = Future<SuccessType, ServiceError>

struct ServiceError: Error {
    let message: String
    let wrappedError: Error?

    init(message: String, wrappedError: Error? = nil) {
        self.message = message
        self.wrappedError = wrappedError
    }
}

struct AppLogging {
    static func debug(_ msg: String) {
        print("DEBUG: \(msg)")
    }
    static func info(_ msg: String) {
        print("INFO: \(msg)")
    }
    static func error(_ msg: String) {
        print("ERR: \(msg)")
    }
}