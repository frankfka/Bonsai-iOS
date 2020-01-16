//
// Created by Frank Jia on 2020-01-15.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

struct PreviewRedux {
    static let initialStore = AppStore(initialState: AppState(), reducer: AppReducer.reduce)
}