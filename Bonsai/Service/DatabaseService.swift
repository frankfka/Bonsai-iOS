//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

protocol DatabaseService {
    // User functions
    func saveUser(user: User) -> ServicePublisher<Void>
    func getUser(userId: String) -> ServicePublisher<User>
    func deleteUser(user: User) -> ServicePublisher<Void>
    func findExistingUserWithGoogleAccount(googleId: String) -> ServicePublisher<User?>

    // LogSearchable functions
    func searchLogSearchables(query: String, by user: User, in category: LogCategory) -> ServicePublisher<[LogSearchable]>
    func getLogSearchable(with id: String, in category: LogCategory) -> ServicePublisher<LogSearchable>
    func saveLogSearchable(logItem: LogSearchable, for user: User) -> ServicePublisher<Void>

    // Log functions
    func saveLog(log: Loggable, for user: User) -> ServicePublisher<Void>
    func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?) -> ServicePublisher<[Loggable]>
    func deleteLog(for user: User, with id: String) -> ServicePublisher<Void>
    // TODO: need to add sync function for saved log searchable/logs on user connect
    // this should upload all logs on first connect, or retrieve lots on resync
    // On relink to existing account, need to clear realm, then add all records from firestore
}

class DatabaseServiceImpl: DatabaseService {

    private let firestoreService: FirebaseFirestoreService
    private let realmService: RealmService

    init() throws {
        self.firestoreService = FirebaseFirestoreService()
        do {
            // Initializing Realm can fail
            self.realmService = try RealmService()
        } catch let error as ServiceError {
            throw error
        }
    }

    func saveUser(user: User) -> ServicePublisher<Void> {
        guard !user.id.isEmpty else {
            return Fail(error: ServiceError(message: "User ID is empty")).eraseToAnyPublisher()
        }
        let future = ServiceFuture<Void> { promise in
            self.firestoreService.saveUser(user: user) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    func deleteUser(user: User) -> ServicePublisher<Void> {
        let future = ServiceFuture<Void> { promise in
            self.firestoreService.deleteUser(user: user) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    func findExistingUserWithGoogleAccount(googleId: String) -> ServicePublisher<User?> {
        let future = ServiceFuture<User?> { promise in
            self.firestoreService.findExistingUserWithGoogleAccount(googleId: googleId) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }


    func searchLogSearchables(query: String, by user: User, in category: LogCategory) -> ServicePublisher<[LogSearchable]> {
        let future = Future<[LogSearchable], ServiceError> { promise in
            self.firestoreService.searchLogSearchable(query: query, by: user, in: category) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    func saveLogSearchable(logItem: LogSearchable, for user: User) -> ServicePublisher<Void> {
        let future = ServiceFuture<Void> { promise in
            self.firestoreService.saveLogSearchable(logItem: logItem, for: user) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    func getLogSearchable(with id: String, in category: LogCategory) -> ServicePublisher<LogSearchable> {
        let future = Future<LogSearchable, ServiceError> { promise in
            self.firestoreService.getLogSearchable(with: id, in: category) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }


    func getUser(userId: String) -> ServicePublisher<User> {
        let future = ServiceFuture<User> { promise in
            self.firestoreService.getUser(userId: userId) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }


    func saveLog(log: Loggable, for user: User) -> ServicePublisher<Void> {
        /*
        Saves the loggable for the user both locally and in Firebase
        - Save in Firebase first, as that is most likely to fail
        - For now, assume that Realm does not fail
        */
        let future = ServiceFuture<Void> { promise in
            self.firestoreService.saveLog(log: log, for: user) { result in
                if case .success = result {
                    // Save to Realm as well
                    let realmErr = self.realmService.saveLog(log: log)
                    if let err = realmErr {
                        AppLogging.warn("Error saving log to Realm, silently swallowing: \(err)")
                    }
                }
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?) -> ServicePublisher<[Loggable]> {
        /*
        Retrieve from Firebase, as it is the ground truth
        - If we have an error, attempt to retrieve from Realm
        - If we have a success, async retrieve from Realm then sync all records together
        */
        let future = ServiceFuture<[Loggable]> { promise in
            self.firestoreService.getLogs(for: user, in: category, since: beginDate, toAndIncluding: endDate) { result in
                let logsFromRealm = self.realmService.getLogs(
                        for: user,
                        in: category,
                        since: beginDate,
                        toAndIncluding: endDate
                )
                // Run additional tasks after retrieving from firestore
                let mappedResult = result
                        .flatMap { firebaseLogs -> Result<[Loggable], ServiceError> in
                            // Success retrieving from firebase, make sure that we update local logs
                            self.updateLocalLogs(firebaseLogs: firebaseLogs, localLogs: logsFromRealm)
                            return .success(firebaseLogs)
                        }.flatMapError { firestoreError -> Result<[Loggable], ServiceError> in
                            // Error retrieving from Firestore, get from Realm instead
                            AppLogging.error("Error retrieving logs from Firestore, defaulting to Realm: \(firestoreError)")
                            // We can't tell if we just don't have any logs or whether the query failed, this silences errors
                            return .success(logsFromRealm)
                        }
                return promise(mappedResult)
            }
        }
        return AnyPublisher(future)
    }

    private func updateLocalLogs(firebaseLogs: [Loggable], localLogs: [Loggable]) {
        // TODO
    }

    func deleteLog(for user: User, with id: String) -> ServicePublisher<Void> {
        /*
        Delete from Firebase first, then from Realm
        - This assumes that Realm transactions are less likely to fail, we swallow these errors for now
        */
        let future = ServiceFuture<Void> { promise in
            self.firestoreService.deleteLog(for: user, with: id) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

}
