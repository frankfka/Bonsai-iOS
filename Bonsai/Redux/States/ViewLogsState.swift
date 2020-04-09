//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct ViewLogsState {
    var isLoading: Bool = false
    var loadError: Error? = nil
    var dateForLogs: Date = Date()
    // View type
    var showLogsByDate: Bool = true
}