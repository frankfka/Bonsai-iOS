//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore

protocol DatabaseService {
    func save(user: User) -> AnyPublisher<User, ServiceError>
    func get(userId: String) -> AnyPublisher<User, ServiceError>
    func search(query: String) -> AnyPublisher<[Medication], ServiceError>
}

class FirebaseService: DatabaseService {

    private let queryLimit = 10  // Number of results to return when a user searches
    private let db: Firestore

    init() {
        self.db = Firestore.firestore()
    }

    func get(userId: String) -> AnyPublisher<User, ServiceError> {
        let future = Future<User, ServiceError> { promise in
            self.get(userId: userId) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func get(userId: String, onComplete: @escaping (Result<User, ServiceError>) -> ()) {
        self.db.collection(FirebaseConstants.UserCollection).document(userId).getDocument { (doc, err) in
            if let err = err {
                AppLogging.error("Error getting user \(err)")
                onComplete(.failure(ServiceError(message: "Error retrieving user \(userId)", wrappedError: err)))
                return
            }
            guard let docData = doc?.data() else {
                onComplete(.failure(ServiceError(message: "User \(userId) has no data")))
                return
            }
            if let user: User = User.decode(data: docData) {
                onComplete(.success(user))
            } else {
                onComplete(.failure(ServiceError(message: "Could not decode user document")))
            }
        }
    }

    func save(user: User) -> AnyPublisher<User, ServiceError> {
        guard !user.id.isEmpty else {
            return Fail(error: ServiceError(message: "User ID is empty")).eraseToAnyPublisher()
        }
        let future = Future<User, ServiceError> { promise in
            self.save(user: user) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func save(user: User, onComplete: @escaping (Result<User, ServiceError>) -> ()) {
        self.db.collection(FirebaseConstants.UserCollection).document(user.id).setData(user.encode()) { err in
            if let err = err {
                AppLogging.error("Error creating new user: \(err)")
                onComplete(.failure(ServiceError(message: "Error creating user", wrappedError: err)))
            } else {
                onComplete(.success(user))
            }
        }
    }

    func search(query: String) -> AnyPublisher<[Medication], ServiceError> {
        let future = Future<[Medication], ServiceError> { promise in
            self.search(query: query) { result in
                promise(result)
            }
        }
        return AnyPublisher(future)
    }

    private func search(query: String, onComplete: @escaping (Result<[Medication], ServiceError>) -> ()) {
        let searchQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        self.db.collection(FirebaseConstants.MedicationCollection)
                .whereField(FirebaseConstants.SearchTermsField, arrayContains: searchQuery)
                .order(by: FirebaseConstants.ItemNameField)
                .limit(to: queryLimit)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        onComplete(.failure(ServiceError(message: "Error in querying \(searchQuery)", wrappedError: err)))
                    } else {
                        var searchResults: [Medication] = []
                        for document in querySnapshot!.documents {
                            if let medication: Medication = Medication.decode(data: document.data()) {
                                searchResults.append(medication)
                            }
                        }
                        onComplete(.success(searchResults))
                    }
                }
    }
}

// Model extensions for encode/decode
extension User {

    func encode() -> [String: Any] {
        return [
            FirebaseConstants.UserIdField: self.id,
            FirebaseConstants.UserDateCreatedField: self.dateCreated
        ]
    }

    static func decode(data: [String: Any]) -> User? {
        let userId = data[FirebaseConstants.UserIdField] as? String
        let dateCreated = (data[FirebaseConstants.UserDateCreatedField] as? Timestamp)?.dateValue()
        if let userId = userId, let dateCreated = dateCreated {
            return User(id: userId, dateCreated: dateCreated)
        }
        return nil
    }
}

extension Medication {

    static func decode(data: [String: Any]) -> Medication? {
        let id = data[FirebaseConstants.MedicationIdField] as? String
        let name = data[FirebaseConstants.ItemNameField] as? String
        if let name = name, let id = id {
            return Medication(id: id, name: name)
        }
        return nil
    }

}