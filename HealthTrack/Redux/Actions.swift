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
    case save

    // Search
    case searchQueryDidChange(query: String)
    case searchResultsDidChange(results: [LogSearchable])
    case searchItemDidSelect(selectedIndex: Int)

    // Medications
    case dosageDidChange(newDosage: String)
}
