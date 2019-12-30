//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct HomeScreenState {
    var isLoading: Bool = false
    var initSuccess: Bool = false
    var initFailure: Error? = nil
    var recentLogs: [Loggable] = []
}