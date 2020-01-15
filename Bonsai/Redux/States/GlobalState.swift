//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct GlobalState {
    var user: User? = nil
    var isInitializing: Bool = false
    var initError: Error? = nil
}