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
    func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?,
                 limit: Int?, offline: Bool) -> ServicePublisher<[Loggable]>
    func deleteLog(for user: User, with id: String) -> ServicePublisher<Void>

    // Local storage functions
    func resetLocalStorage() -> ServicePublisher<Void> // Called when user restores, all local logs are to be cleared
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
                let mappedResult = result.flatMap { () -> Result<Void, ServiceError> in
                    // Save to Realm as well
                    let realmErr = self.realmService.saveLogs(logs: [log])
                    if let err = realmErr {
                        AppLogging.warn("Error saving log to Realm, silently swallowing: \(err)")
                    }
                    return .success(())
                }
                promise(mappedResult)
            }
        }
        return AnyPublisher(future)
    }

    func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?,
                 limit: Int?, offline: Bool) -> ServicePublisher<[Loggable]> {
        /*
        Retrieve from Firebase, as it is the ground truth
        - If we have an error, attempt to retrieve from Realm
        - If we have a success, async retrieve from Realm then sync all records together
        */
        let future = ServiceFuture<[Loggable]> { promise in
            let logsFromRealm = self.realmService.getLogs(
                    for: user,
                    in: category,
                    since: beginDate,
                    toAndIncluding: endDate,
                    limit: limit
            )
            if offline {
                // Don't attempt to retrieve from Firebase
                return promise(.success(logsFromRealm))
            }
            self.firestoreService.getLogs(for: user, in: category, since: beginDate,
                    toAndIncluding: endDate, limitedTo: limit) { result in
                // Run additional tasks after retrieving from firestore
                let mappedResult = result
                        .flatMap { firebaseLogs -> Result<[Loggable], ServiceError> in
                            // Success retrieving from firebase, make sure that we update local logs
                            self.updateLocalLogs(firebaseLogs: firebaseLogs, realmLogs: logsFromRealm)
                            // Enforce reverse chronological order
                            let sortedFirebaseLogs = firebaseLogs.sorted { first, second in first.dateCreated > second.dateCreated }
                            return .success(sortedFirebaseLogs)
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

    private func updateLocalLogs(firebaseLogs: [Loggable], realmLogs: [Loggable]) {
        /*
        Adds logs to local storage if they don't exist locally but were fetched from Firestore
        Delete logs from local storage if they were fetched but do not exist in Firestore
        - IMPORTANT: This should only be called when we have the conditions on fetching from Firebase & Realm,
          else we would unnecessarily delete/add logs
        - This is not too performant, but since we're not dealing with large # logs each time, should be OK.
          Since UI doesn't depend on this, we can do these operations asynchronously
        - TODO: RealmService needs to support async operations
        */
        // Get logs to add
        var logsToAdd: [Loggable] = []
        for firebaseLog in firebaseLogs {
            // Present in Firebase results but not Realm
            if realmLogs.first(where: { realmLog in realmLog.id == firebaseLog.id }) == nil {
                AppLogging.info("Could not find log \(firebaseLog.id) locally, adding to Realm")
                logsToAdd.append(firebaseLog)
            }
        }
        if !logsToAdd.isEmpty {
            if let err = self.realmService.saveLogs(logs: logsToAdd) {
                AppLogging.warn("Some logs weren't saved in local update: \(err)")
            }
        } else {
            AppLogging.debug("Local Realm storage not missing any entries")
        }
        // Get logs to delete
        var logIdsToDelete: [String] = []
        for realmLog in realmLogs {
            // Present in Realm but not Firebase
            if firebaseLogs.first(where: { firebaseLog in firebaseLog.id == realmLog.id }) == nil {
                AppLogging.info("Log \(realmLog.id) exists locally but not from Firebase, Deleting from Realm")
                logIdsToDelete.append(realmLog.id)
            }
        }
        if !logIdsToDelete.isEmpty {
            if let err = self.realmService.deleteLogs(with: logIdsToDelete) {
                AppLogging.warn("Some logs weren't deleted in local update: \(err)")
            }
        } else {
            AppLogging.debug("Local Realm storage does not have any duplicate entries")
        }
    }

    func deleteLog(for user: User, with id: String) -> ServicePublisher<Void> {
        /*
        Delete from Firebase first, then from Realm
        - This assumes that Realm transactions are less likely to fail, we swallow these errors for now
        */
        let future = ServiceFuture<Void> { promise in
            self.firestoreService.deleteLog(for: user, with: id) { result in
                // Delete locally if firestore succeeds
                let mappedResult = result.flatMap { _ -> Result<Void, ServiceError> in
                    if let err = self.realmService.deleteLogs(with: [id]) {
                        AppLogging.warn("Error deleting Realm log \(id): \(err)")
                    }
                    return .success(())
                }
                promise(mappedResult)
            }
        }
        return AnyPublisher(future)
    }

    func resetLocalStorage() -> ServicePublisher<Void> {
        let future = ServiceFuture<Void> { promise in
            let deletionErr = self.realmService.deleteAllObjects()
            if let deletionErr = deletionErr {
                promise(.failure(deletionErr))
                return
            }
            promise(.success(()))
        }
        return AnyPublisher(future)
    }

}
