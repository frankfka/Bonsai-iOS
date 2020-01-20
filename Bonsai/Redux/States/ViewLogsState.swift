//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

// TODO: store a dictionary of date to logs, then we don't need to keep reloading
struct ViewLogsState {
    var isLoading: Bool = false
    var loadError: Error? = nil
    var dateForLogs: Date = Date()
    var logs: [Loggable] = []
}