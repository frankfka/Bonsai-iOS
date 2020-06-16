//
// Created by Frank Jia on 2020-03-11.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

enum GlobalAction: LoggableAction {
    // On app launch
    case appDidLaunch
    case initSuccess(user: User)
    case initFailure(error: Error)

    // Navigation
    case changeCreateLogModalDisplay(shouldDisplay: Bool)

    // Permissions
    case notificationPermissionsInit(isEnabled: Bool) // Dispatched when we first check on app launch - this triggers scheduling of notifications, but otherwise has same effect
    case notificationPermissionsDidChange(isEnabled: Bool)
    case errorProcessingNotificationPermissions(error: Error) // Dispatched when we have error retrieving notifications/asking for them
}