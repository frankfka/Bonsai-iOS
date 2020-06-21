//
//  AppReducer.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-12.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

protocol AppServices {
    var notificationService: NotificationService { get }
    var userService: UserService { get }
    var logService: LogService { get }
    var logReminderService: LogReminderService { get }
    var analyticsService: AnalyticsService { get }
}
class AppServicesImpl: AppServices {
    let notificationService: NotificationService
    let userService: UserService
    let logService: LogService
    let logReminderService: LogReminderService
    let analyticsService: AnalyticsService

    init() throws {
        // Init serves as dependency management
        let db = try DatabaseServiceImpl()
        let cache = CacheServiceImpl()
        let firebaseAuthService = FirebaseAuthService()
        notificationService = NotificationServiceImpl()
        userService = UserServiceImpl(db: db, auth: firebaseAuthService)
        logService = LogServiceImpl(db: db, cache: cache)
        logReminderService = LogReminderServiceImpl(db: db, notificationService: notificationService)
        analyticsService = AnalyticsServiceImpl(db: db)
    }
}
struct AppState {
    // General app related stuff
    var global: GlobalState
    // All logs
    var globalLogs: GlobalLogState
    // All log reminders
    var globalLogReminders: GlobalLogReminderState
    // Home tab
    var homeScreen: HomeScreenState
    // View logs tab
    var viewLogs: ViewLogsState
    // Log Details page
    var logDetails: LogDetailState
    // Log Reminder Details page
    var logReminderDetails: LogReminderDetailState
    // Settings page
    var settings: SettingsState
    // Create log
    var createLog: CreateLogState
    // Create/Edit log reminder
    var createLogReminder: CreateLogReminderState

    init(
        global: GlobalState = GlobalState(),
        globalLogs: GlobalLogState = GlobalLogState(),
        globalLogReminders: GlobalLogReminderState = GlobalLogReminderState(),
        homeScreen: HomeScreenState = HomeScreenState(),
        viewLogs: ViewLogsState = ViewLogsState(),
        logDetails: LogDetailState = LogDetailState(),
        logReminderDetails: LogReminderDetailState = LogReminderDetailState(),
        settings: SettingsState = SettingsState(),
        createLog: CreateLogState = CreateLogState(),
        createLogReminder: CreateLogReminderState = CreateLogReminderState()
    ) {
        self.global = global
        self.globalLogs = globalLogs
        self.globalLogReminders = globalLogReminders
        self.homeScreen = homeScreen
        self.viewLogs = viewLogs
        self.logDetails = logDetails
        self.logReminderDetails = logReminderDetails
        self.settings = settings
        self.createLog = createLog
        self.createLogReminder = createLogReminder
    }
}
struct AppMiddleware {
    static func getMiddleware(services: AppServices) -> [Middleware<AppState>] {
        var middleware: [Middleware<AppState>] = []
        // Action Logging
        middleware.append(loggingMiddleware())
        // App init
        middleware.append(contentsOf: AppInitMiddleware.middleware(services: services))
        // Global Logs
        middleware.append(contentsOf: GlobalLogsMiddleware.middleware(services: services))
        // Global Log Reminders
        middleware.append(contentsOf: GlobalLogRemindersMiddleware.middleware(services: services))
        // Home screen
        middleware.append(contentsOf: HomeScreenMiddleware.middleware(services: services))
        // View logs
        middleware.append(contentsOf: ViewLogsMiddleware.middleware(services: services))
        // Log Detail
        middleware.append(contentsOf: LogDetailMiddleware.middleware(services: services))
        // Log Reminder Detail
        middleware.append(contentsOf: LogReminderDetailMiddleware.middleware(services: services))
        // Settings
        middleware.append(contentsOf: SettingsMiddleware.middleware(services: services))
        // Create log
        middleware.append(contentsOf: CreateLogMiddleware.middleware(services: services))
        // Create log reminder
        middleware.append(contentsOf: CreateLogReminderMiddleware.middleware(services: services))
        
        return middleware
    }
}
