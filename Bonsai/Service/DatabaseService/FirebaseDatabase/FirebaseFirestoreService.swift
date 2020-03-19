//
// Created by Frank Jia on 2019-12-25.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore

class FirebaseFirestoreService {

    private let linkedGoogleAccountQueryLimit = 1 // Number of results to return when we look for a linked Google account
    private let logQueryLimit = 50 // Highest number of results to return when user sees logs
    private let logSearchableQueryLimit = 10  // Number of results to return when a user searches
    private let db: Firestore

    init() {
        self.db = Firestore.firestore()
    }

    func getUser(userId: String, onComplete: @escaping ServiceCallback<User>) {
        self.db.collection(SerializationConstants.User.Collection).document(userId).getDocument { (doc, err) in
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

    func saveUser(user: User, onComplete: @escaping ServiceCallback<Void>) {
        self.db.collection(SerializationConstants.User.Collection)
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

    func deleteUser(user: User, onComplete: @escaping ServiceCallback<Void>) {
        // TODO: This does not delete log subcollections
        self.db.collection(SerializationConstants.User.Collection).document(user.id).delete() { err in
            if let err = err {
                let errorMessage = "Error deleting user \(user.id): \(err)"
                AppLogging.error(errorMessage)
                onComplete(.failure(ServiceError(message: errorMessage, wrappedError: err)))
            } else {
                onComplete(.success(()))
            }
        }
    }

    func findExistingUserWithGoogleAccount(googleId: String, onComplete: @escaping ServiceCallback<User?>) {
        self.db.collection(SerializationConstants.User.Collection)
                .whereField("\(SerializationConstants.User.LinkedGoogleAccountField).\(SerializationConstants.User.FirebaseGoogleAccount.IdField)", isEqualTo: googleId)
                .limit(to: linkedGoogleAccountQueryLimit)  // Should not have more than 1 linked user
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        let errString = "Error in finding user with linked Google account ID \(googleId): \(err)"
                        AppLogging.error(errString)
                        onComplete(.failure(ServiceError(message: errString, wrappedError: err)))
                    } else {
                        var linkedUser: User? = nil
                        if let foundDocument = querySnapshot!.documents.first?.data(),
                            let foundUser = User.decode(data: foundDocument) {
                            linkedUser = foundUser
                            AppLogging.info("Found user ID \(foundUser.id) already linked to Google ID \(googleId)")
                        }
                        onComplete(.success(linkedUser))
                    }
                }
    }

    func searchLogSearchable(query: String, by user: User, in category: LogCategory, onComplete: @escaping ServiceCallback<[LogSearchable]>) {
        let searchQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let collectionName = category.firebaseLogSearchableCollectionName() else {
            onComplete(.failure(ServiceError(message: "Not a searchable category")))
            return
        }
        self.db.collection(collectionName)
                // Search the searchTerms array for match
                .whereField(SerializationConstants.Searchable.SearchTermsField, arrayContains: searchQuery)
                // Limit to commonly available items + items created by user
                .whereField(
                        SerializationConstants.Searchable.CreatedByField,
                        in: [SerializationConstants.Searchable.CreatedByMaster, user.id])
                // Order by name
                .order(by: SerializationConstants.Searchable.ItemNameField)
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

    func getLogSearchable(with id: String, in category: LogCategory, onComplete: @escaping ServiceCallback<LogSearchable>) {
        guard let collectionName = category.firebaseLogSearchableCollectionName() else {
            onComplete(.failure(ServiceError(message: "Invalid Log Searchable category \(category)")))
            return
        }
        AppLogging.debug("Finding \(id) in \(collectionName)")
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

    func saveLogSearchable(logItem: LogSearchable, for user: User, onComplete: @escaping ServiceCallback<Void>) {
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

    func saveLog(log: Loggable, for user: User, onComplete: @escaping ServiceCallback<Void>) {
        self.db.collection(SerializationConstants.User.Collection)
                .document(user.id)
                .collection(SerializationConstants.Logs.Collection)
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

    func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?,
                 limitedTo: Int?, startingAfterLog: Loggable?, onComplete: @escaping ServiceCallback<[Loggable]>) {
        // If we want to paginate, get the document snapshot first
        if let startingAfterLog = startingAfterLog {
            getLogDocumentSnapshot(for: user, with: startingAfterLog) { result in
                switch result {
                case .success(let snapshot):
                    // Call private func with the snapshot
                    self.getLogs(for: user, in: category, since: beginDate, toAndIncluding: endDate, limitedTo: limitedTo,
                            startingAfterDoc: snapshot, onComplete: onComplete)
                case .failure(let err):
                    onComplete(.failure(err))
                }
            }
        } else {
            // No pagination, call private func directly
            getLogs(for: user, in: category, since: beginDate, toAndIncluding: endDate, limitedTo: limitedTo,
                    startingAfterDoc: nil, onComplete: onComplete)
        }
    }

    private func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?,
                         limitedTo: Int?, startingAfterDoc: DocumentSnapshot?, onComplete: @escaping ServiceCallback<[Loggable]>) {
        var q = self.db.collection(SerializationConstants.User.Collection)
                .document(user.id)
                .collection(SerializationConstants.Logs.Collection)
                .order(by: SerializationConstants.Logs.DateCreatedField, descending: true)
        // Query starting at a snapshot if specified
        if let startingAfterDoc = startingAfterDoc {
            q = q.start(afterDocument: startingAfterDoc)
        }
        // Query by date if specified
        if let beginDate = beginDate {
            q = q.whereField(SerializationConstants.Logs.DateCreatedField, isGreaterThanOrEqualTo: beginDate)
        }
        if let endDate = endDate {
            q = q.whereField(SerializationConstants.Logs.DateCreatedField, isLessThanOrEqualTo: endDate)
        }
        q = q.limit(to: limitedTo ?? logQueryLimit)
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

    // Retrieve a document snapshot for pagination
    private func getLogDocumentSnapshot(for user: User, with loggable: Loggable, onComplete: @escaping ServiceCallback<DocumentSnapshot>) {
        self.db.collection(SerializationConstants.User.Collection)
                .document(user.id)
                .collection(SerializationConstants.Logs.Collection)
                .document(loggable.id)
                .addSnapshotListener { (doc, err) in
                    guard err == nil else {
                        let errMsg = "Error from Firebase for retrieving snapshot for Loggable \(loggable.id)"
                        AppLogging.error(errMsg)
                        onComplete(
                            .failure(
                                ServiceError(
                                        message: errMsg,
                                        wrappedError: err
                                )
                            )
                        )
                        return
                    }
                    guard let doc = doc, doc.exists else {
                        let errMsg = "Could not retrieve snapshot document for Loggable \(loggable.id)"
                        AppLogging.error(errMsg)
                        onComplete(
                            .failure(
                                ServiceError(
                                    message: errMsg,
                                    wrappedError: err
                                )
                            )
                        )
                        return
                    }
                    onComplete(.success(doc))
                }
    }

    func deleteLog(for user: User, with id: String, onComplete: @escaping ServiceCallback<Void>) {
        self.db.collection(SerializationConstants.User.Collection).document(user.id)
                .collection(SerializationConstants.Logs.Collection).document(id).delete() { err in
                    if let err = err {
                        onComplete(.failure(ServiceError(message: "Error deleting log \(id) for user \(user.id)", wrappedError: err)))
                    } else {
                        onComplete(.success(()))
                    }
                }
    }

}
