//
//  AppStore.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-11.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Combine
import Foundation

typealias Reducer<State, Action> = (State, AppAction) -> State
typealias Dispatch = (AppAction) -> Void
typealias Middleware<State> = (State, AppAction, inout Set<AnyCancellable>, @escaping Dispatch) -> Void

final class AppStore: ObservableObject {
    @Published private(set) var state: AppState
    private let reducer: Reducer<AppState, AppAction>
    private let middleware: [Middleware<AppState>]
    private var cancellables: Set<AnyCancellable> = []

    init(initialState: AppState, reducer: @escaping Reducer<AppState, AppAction>, middleware: [Middleware<AppState>] = []) {
        self.state = initialState
        self.reducer = reducer
        self.middleware = middleware
    }
    
    // Sync actions
    func send(_ action: AppAction) {
        state = self.reducer(state, action)
        self.middleware.forEach { m in
            m(state, action, &cancellables, send)
        }
    }
}
