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

// This is a global variable
let globalStore: AppStore = {
    let services = try! AppServicesImpl()
    return AppStore(
        initialState: AppState(),
        reducer: AppReducer.reduce,
        services: services,
        middleware: AppMiddleware.getMiddleware(services: services)
    )
}()
class AppStore: NSObject, ObservableObject {
    @Published var state: AppState
    private let reducer: Reducer<AppState, AppAction>
    private let middleware: [Middleware<AppState>]
    let services: AppServices
    var cancellables: Set<AnyCancellable> = []

    init(initialState: AppState,
         reducer: @escaping Reducer<AppState, AppAction>,
         services: AppServices,
         middleware: [Middleware<AppState>] = []
    ) {
        self.state = initialState
        self.reducer = reducer
        self.middleware = middleware
        self.services = services
    }
    
    // Sync actions
    func send(_ action: AppAction) {
        state = self.reducer(state, action)
        self.middleware.forEach { m in
            m(state, action, &cancellables, sendThroughMiddleware)
        }
    }

    func sendThroughMiddleware(_ action: AppAction) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.send(action)
        }
    }

    // MARK: Publishers to communicate programmatic navigation
    @Published var showCreateLogModal: Bool = false
}
