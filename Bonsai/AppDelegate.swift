//
//  AppDelegate.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-05.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        globalStore.send(.global(action: .appDidLaunch))

        let navigationBarAppearace = UINavigationBar.appearance()
        // TODO: Using unmonitored UIColor here
        navigationBarAppearace.backgroundColor = .systemBackground
        navigationBarAppearace.barTintColor = .systemBackground
        navigationBarAppearace.tintColor = Color.Theme.primaryUIColor
        return true
    }

    // MARK: Firebase Auth
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        globalServices.userService.googleSignedIn(signIn, didSignInFor: user, withError: error)
    }
    // Not supporting below iOS 9
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
                    -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

