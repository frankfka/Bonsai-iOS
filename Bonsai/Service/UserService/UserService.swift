//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Combine
import Foundation

import GoogleSignIn

protocol UserService {
    func createUser() -> User
    func save(user: User) -> ServicePublisher<Void>
    func get(userId: String) -> ServicePublisher<User>

    func findExistingUserWithGoogleAccount(googleAccount: User.FirebaseGoogleAccount) -> ServicePublisher<User?>
    func restoreUser(currentUser: User, userToRestore: User) -> ServicePublisher<Void>

    // Firebase Integrations - separate from the core service
    func signInWithGoogle(presentingVc: UIViewController)
    func googleSignedIn(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
}

class UserServiceImpl: UserService {
    private let db: DatabaseService
    private let auth: FirebaseAuthService

    init(db: DatabaseService, auth: FirebaseAuthService) {
        self.auth = auth
        self.db = db
    }

    func createUser() -> User {
        let id = UUID().uuidString
        return User(id: id, dateCreated: Date())
    }

    func save(user: User) -> ServicePublisher<Void> {
        return self.db.saveUser(user: user)
    }

    func get(userId: String) -> ServicePublisher<User> {
        return self.db.getUser(userId: userId)
    }

    func findExistingUserWithGoogleAccount(googleAccount: User.FirebaseGoogleAccount) -> ServicePublisher<User?> {
        return self.db.findExistingUserWithGoogleAccount(googleId: googleAccount.id)
    }

    func restoreUser(currentUser: User, userToRestore: User) -> ServicePublisher<Void> {
        // Delete all local logs and delete the userID from local storage
        Publishers.CombineLatest(self.db.deleteUser(user: currentUser), self.db.resetLocalStorage()).map { _ in
            AppLogging.info("Deleted user \(currentUser.id) and purged all local log records")
            // Set local ID to the new user
            UserDefaults.standard.set(userToRestore.id, forKey: UserConstants.UserDefaultsUserIdKey)
            AppLogging.info("Set user \(userToRestore.id) as default user in UserDefaults")
        }
        .eraseToAnyPublisher()
    }

    // MARK: Firebase Integrations
    func signInWithGoogle(presentingVc: UIViewController) {
        self.auth.signInWithGoogle(presentingVc: presentingVc)
    }

    func googleSignedIn(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // Delegate to firebase service
        return self.auth.googleSignedIn(signIn, didSignInFor: user, withError: error)
    }
}
