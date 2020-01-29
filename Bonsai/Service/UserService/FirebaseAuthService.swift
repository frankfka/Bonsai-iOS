//
// Created by Frank Jia on 2020-01-25.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

import FirebaseAuth
import GoogleSignIn

class FirebaseAuthService {

    // Called when user kicks off the login flow
    func signInWithGoogle(presentingVc: UIViewController) {
        GIDSignIn.sharedInstance()?.presentingViewController = presentingVc
        GIDSignIn.sharedInstance()?.signIn()
    }

    // Direct interfacing code with Firebase Auth
    func googleSignedIn(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // Handle Firebase auth logic here - then dispatch the appropriate action to re-interface with the app
        if let error = error {
            globalStore.send(.settings(action: .googleSignInError(error: error)))
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                globalStore.send(.settings(action: .googleSignInError(error: error)))
                return
            }
            // Sign in was successful
            AppLogging.info("Google user \(user.userID ?? "") signed in ")
            globalStore.send(
                    .settings(
                            action: .googleSignedIn(
                                    googleAccount: User.FirebaseGoogleAccount(
                                            id: user.userID,
                                            name: user.profile.name,
                                            email: user.profile.email
                                    )
                            )
                    )
            )
        }
    }


    func signOutFromGoogle() -> Error? {
        let firebaseAuth = Auth.auth()
        guard firebaseAuth.currentUser != nil else {
            // We don't require a consistent session since we only need sign-in to backup/restore
            // So it is normal for Firebase to not be signed in
            AppLogging.info("No currently signed in user for Firebase Auth, skipping sign out")
            return nil
        }
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            AppLogging.error("Could not sign out user \(signOutError)")
            return signOutError
        }
        return nil
    }

}
