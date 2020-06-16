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


// Calls all the necessary functions to initialize the app
fileprivate func initializeApp(with store: AppStore) {
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    GIDSignIn.sharedInstance().delegate = globalStore

    // Configure notifications
    UNUserNotificationCenter.current().delegate = globalStore

    // Notify on app launch
    globalStore.send(.global(action: .appDidLaunch))

    // Configure navigation bar
    let navigationBarAppearance = UINavigationBar.appearance()
    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.configureWithOpaqueBackground()
    navBarAppearance.backgroundColor = Color.Theme.NavBarBackground
    navigationBarAppearance.tintColor = Color.Theme.PrimaryUIColor
    navigationBarAppearance.standardAppearance = navBarAppearance
    navigationBarAppearance.scrollEdgeAppearance = navBarAppearance
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase - must be done first
        FirebaseApp.configure()
        initializeApp(with: globalStore)
        return true
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

