//
// Created by Frank Jia on 2020-06-09.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import GoogleSignIn

extension AppStore: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        self.services.userService.googleSignedIn(signIn, didSignInFor: user, withError: error)
    }

    // Not supporting below iOS 9
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
            -> Bool {
        GIDSignIn.sharedInstance().handle(url)
    }
}