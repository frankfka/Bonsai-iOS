//
//  Actions.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-11.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

enum AppAction {
    case global(action: GlobalAction)
    case createLog(action: CreateLogAction)
}

enum GlobalAction {
    // On app launch
    case appDidLaunch
    case initSuccess(user: User)
    case initFailure(error: Error)
}

enum CreateLogAction {
    case screenDidShow
    case screenDidDismiss
    case logCategoryDidChange(newIndex: Int)
    case noteDidUpdate(note: String)

    // Search
    case searchQueryDidChange(query: String)
    case searchDidComplete(results: [LogSearchable])
    case searchItemDidSelect(selectedIndex: Int)
    case onAddSearchItemPressed(name: String)
    case onAddSearchItemSuccess(addedItem: LogSearchable)
    case onAddSearchItemFailure(error: Error)
    case onAddSearchResultPopupShown

    // Medications
    case dosageDidChange(newDosage: String)

    // Save
    case onCreateLogPressed
    case onCreateLogSuccess
    case onCreateLogFailure(error: Error)
    case createErrorShown
}
