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

    static let DoesNotExistInDatabaseError = "DOES_NOT_EXIST_IN_DB"

    let message: String
    let wrappedError: Error?
    let reason: String? // Allows conditional actions based on errors

    init(message: String, wrappedError: Error? = nil, reason: String? = nil) {
        self.message = message
        self.wrappedError = wrappedError
        self.reason = reason
    }
}

struct AppLogging {
    static func debug(_ msg: String) {
        print("DEBUG: \(msg)")
    }
    static func info(_ msg: String) {
        print("INFO: \(msg)")
    }
    static func warn(_ msg: String) {
        print("WARN: \(msg)")
    }
    static func error(_ msg: String) {
        print("ERR: \(msg)")
    }
}