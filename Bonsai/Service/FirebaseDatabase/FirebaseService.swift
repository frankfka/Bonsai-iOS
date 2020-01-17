//
// Created by Frank Jia on 2019-12-25.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore

class FirebaseService: DatabaseService {

    private let logQueryLimit = 10 // Number of results to return when user sees logs
    private let logSearchableQueryLimit = 10  // Number of results to return when a user searches
    private let db: Firestore

    init() {
        self.db = Firestore.firestore()
    }

    func getUser(userId: String) -> ServicePublisher<User> {
        let future = ServiceFuture<User> { promise in
            self.get(userId: userId) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func get(userId: String, onComplete: @escaping ServiceCallback<User>) {
        self.db.collection(FirebaseConstants.User.Collection).document(userId).getDocument { (doc, err) in
            if let err = err {
                AppLogging.error("Error getting user \(userId) \(err)")
                onComplete(.failure(ServiceError(message: "Error retrieving user \(userId)", wrappedError: err)))
                return
            }
            guard let doc = doc, doc.exists else {
                AppLogging.error("User \(userId) does not exist in Firebase")
                // Tell handler to delete the user default ID
                onComplete(.failure(ServiceError(message: "User \(userId) does not exist in Firebase", reason: ServiceError.DoesNotExistInDatabaseError)))
                return
            }
            guard let docData = doc.data() else {
                AppLogging.error("User \(userId) has no data")
                // Tell handler to delete the user default ID
                onComplete(.failure(ServiceError(message: "User \(userId) has no data", reason: ServiceError.DoesNotExistInDatabaseError)))
                return
            }
            if let user: User = User.decode(data: docData) {
                AppLogging.debug("User \(userId) retrieved successfully")
                onComplete(.success(user))
            } else {
                AppLogging.error("User \(userId) could not be decoded")
                onComplete(.failure(ServiceError(message: "Could not decode user document")))
            }
        }
    }

    func saveUser(user: User) -> ServicePublisher<Void> {
        guard !user.id.isEmpty else {
            return Fail(error: ServiceError(message: "User ID is empty")).eraseToAnyPublisher()
        }
        let future = ServiceFuture<Void> { promise in
            self.save(user: user) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func save(user: User, onComplete: @escaping ServiceCallback<Void>) {
        self.db.collection(FirebaseConstants.User.Collection)
                .document(user.id)
                .setData(user.encode()) { err in
                    if let err = err {
                        AppLogging.error("Error creating new user: \(err)")
                        onComplete(.failure(ServiceError(message: "Error creating user", wrappedError: err)))
                    } else {
                        AppLogging.debug("User \(user.id) saved successfully")
                        onComplete(.success(()))
                    }
                }
    }

    func searchLogSearchables(query: String, by user: User, in category: LogCategory) -> ServicePublisher<[LogSearchable]> {
        let future = Future<[LogSearchable], ServiceError> { promise in
            self.search(query: query, by: user, in: category) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func search(query: String, by user: User, in category: LogCategory, onComplete: @escaping ServiceCallback<[LogSearchable]>) {
        let searchQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let collectionName = category.firebaseLogSearchableCollectionName() else {
            onComplete(.failure(ServiceError(message: "Not a searchable category")))
            return
        }
        self.db.collection(collectionName)
                // Search the searchTerms array for match
                .whereField(FirebaseConstants.Searchable.SearchTermsField, arrayContains: searchQuery)
                // Limit to commonly available items + items created by user
                .whereField(
                        FirebaseConstants.Searchable.CreatedByField,
                        in: [FirebaseConstants.Searchable.CreatedByMaster, user.id])
                // Order by name
                .order(by: FirebaseConstants.Searchable.ItemNameField)
                // Limit results
                .limit(to: logSearchableQueryLimit)
                .getDocuments() { [weak self] (querySnapshot, err) in
                    if let err = err {
                        AppLogging.error("Error in searching \(searchQuery): \(err)")
                        onComplete(.failure(ServiceError(message: "Error in querying \(searchQuery)", wrappedError: err)))
                    } else {
                        var searchResults: [LogSearchable] = []
                        for document in querySnapshot!.documents {
                            if let searchResult: LogSearchable = self?.decode(data: document.data(), parentCategory: category) {
                                searchResults.append(searchResult)
                            }
                        }
                        AppLogging.debug("Searched \(searchQuery) successfully with \(searchResults.count) items")
                        onComplete(.success(searchResults))
                    }
                }
    }

    func getLogSearchable(with id: String, in category: LogCategory) -> ServicePublisher<LogSearchable> {
        let future = Future<LogSearchable, ServiceError> { promise in
            self.get(with: id, in: category) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func get(with id: String, in category: LogCategory, onComplete: @escaping ServiceCallback<LogSearchable>) {
        guard let collectionName = category.firebaseLogSearchableCollectionName() else {
            onComplete(.failure(ServiceError(message: "Invalid Log Searchable category \(category)")))
            return
        }
        self.db.collection(collectionName).document(id).getDocument { (doc, err) in
            guard err == nil else {
                onComplete(.failure(ServiceError(message: "Error retrieving log searchable with ID \(id)", wrappedError: err)))
                return
            }
            guard let doc = doc, doc.exists, let docData = doc.data() else {
                onComplete(.failure(ServiceError(message: "Log Searchable with ID \(id) not found", wrappedError: nil)))
                return
            }
            if let result: LogSearchable = self.decode(data: docData, parentCategory: category) {
                onComplete(.success(result))
            } else {
                onComplete(.failure(ServiceError(message: "Could not decode log searchable with ID \(id)")))
            }
        }
    }

    func saveLogSearchable(logItem: LogSearchable, for user: User) -> ServicePublisher<Void> {
        let future = ServiceFuture<Void> { promise in
            self.save(logItem: logItem, for: user) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func save(logItem: LogSearchable, for user: User, onComplete: @escaping ServiceCallback<Void>) {
        guard let collectionName = logItem.parentCategory.firebaseLogSearchableCollectionName() else {
            onComplete(.failure(ServiceError(message: "Not a searchable category")))
            return
        }
        self.db.collection(collectionName)
                .document(logItem.id)
                .setData(logItem.encode()) { err in
                    if let err = err {
                        AppLogging.error("Error adding log item \(logItem.id) with parent user \(user.id): \(err)")
                        onComplete(.failure(ServiceError(message: "Error saving log item", wrappedError: err)))
                        return
                    } else {
                        AppLogging.debug("Log item saved successfully")
                        onComplete(.success(()))
                        return
                    }
                }
    }

    func saveLog(log: Loggable, for user: User) -> ServicePublisher<Void> {
        let future = ServiceFuture<Void> { promise in
            self.save(log: log, for: user) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func save(log: Loggable, for user: User, onComplete: @escaping ServiceCallback<Void>) {
        self.db.collection(FirebaseConstants.User.Collection)
                .document(user.id)
                .collection(FirebaseConstants.Logs.Collection)
                .document(log.id)
                .setData(log.encode()) { err in
                    if let err = err {
                        AppLogging.error("Error adding log \(log.id) to user \(user.id): \(err)")
                        onComplete(.failure(ServiceError(message: "Error saving log", wrappedError: err)))
                        return
                    } else {
                        AppLogging.debug("Log saved successfully")
                        onComplete(.success(()))
                        return
                    }
                }
    }

    func getLog(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?) -> ServicePublisher<[Loggable]> {
        let future = ServiceFuture<[Loggable]> { promise in
            self.get(for: user, in: category, since: beginDate, toAndIncluding: endDate) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func get(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?,
                     onComplete: @escaping ServiceCallback<[Loggable]>) {
        var q = self.db.collection(FirebaseConstants.User.Collection)
                .document(user.id)
                .collection(FirebaseConstants.Logs.Collection)
                .order(by: FirebaseConstants.Logs.DateCreatedField, descending: true)
                .limit(to: logQueryLimit)
        // Query by date if specified
        if let beginDate = beginDate {
            q = q.whereField(FirebaseConstants.Logs.DateCreatedField, isGreaterThanOrEqualTo: beginDate)
        }
        if let endDate = endDate {
            q = q.whereField(FirebaseConstants.Logs.DateCreatedField, isLessThanOrEqualTo: endDate)
        }
        // Perform query
        q.getDocuments() { [weak self] (querySnapshot, err) in
            if let err = err {
                AppLogging.error("Error in fetching logs for user \(user.id): \(err)")
                onComplete(
                        .failure(
                                ServiceError(
                                        message: "Error in fetching logs for user \(user.id): \(err)",
                                        wrappedError: err
                                )
                        )
                )
            } else {
                var fetchedLogs: [Loggable] = []
                for document in querySnapshot!.documents {
                    if let logResult: Loggable = self?.decode(data: document.data()) {
                        fetchedLogs.append(logResult)
                    } else {
                        AppLogging.warn("Could not decode log")
                    }
                }
                AppLogging.debug("Fetched logs successfully for user \(user.id) with \(fetchedLogs.count) items")
                onComplete(.success(fetchedLogs))
            }
        }
    }

    func deleteLog(for user: User, with id: String) -> ServicePublisher<Void> {
        let future = ServiceFuture<Void> { promise in
            self.deleteLog(for: user, with: id) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func deleteLog(for user: User, with id: String, onComplete: @escaping ServiceCallback<Void>) {
        self.db.collection(FirebaseConstants.User.Collection).document(user.id)
                .collection(FirebaseConstants.Logs.Collection).document(id).delete() { err in
                    if let err = err {
                        onComplete(.failure(ServiceError(message: "Error deleting log \(id) for user \(user.id)", wrappedError: err)))
                    } else {
                        onComplete(.success(()))
                    }
                }
    }

}
