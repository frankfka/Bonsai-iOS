//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Combine
import Foundation

func createLogSearchMiddleware(logService: LogService) -> Middleware<AppState> {
    return { state, action, cancellables, send in
        switch action {
        case let .createLog(action: .searchQueryDidChange(newQuery)):
            // Check user exists
            guard let user = state.global.user else {
                fatalError("No user initialized when searching")
            }
            // Perform search
            search(logService: logService, with: newQuery, for: user, in: state.createLog.selectedCategory)
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
        default:
            break
        }
    }
}

private func search(logService: LogService, with query: String, for user: User, in category: LogCategory) -> AnyPublisher<AppAction, Never> {
    if query.isEmptyWithoutWhitespace() {
        // Don't perform a query, just return empty results
        // TODO: Figure out thread access
//        return Just(AppAction.createLog(action: .searchDidComplete(results: []))).eraseToAnyPublisher()
    }
    return logService.search(with: query, by: user, in: category)
            .map { results in
                return AppAction.createLog(action: .searchDidComplete(results: results))
            }.catch { (err) -> Just<AppAction> in
                return Just(AppAction.createLog(action: .searchDidComplete(results: [])))
            }
            .eraseToAnyPublisher()
}

// TODO: Add these to app middleware
//func createLogAddNewItemMiddleware() -> Middleware<AppState> {
//
//}

func createLogOnSaveMiddleware(logService: LogService) -> Middleware<AppState> {
    return { state, action, cancellables, send in
        switch action {
        case .createLog(action: .onCreateLogPressed):
            // Check user exists
            guard let user = state.global.user else {
                fatalError("No user initialized when searching")
            }
            // Check that the log state is valid
            guard let newLog = createLogFromState(state: state.createLog) else {
                doInMiddleware {
                    send(.createLog(action: .onCreateLogFailure(error: AppError(message: "Could not parse log state"))))
                }
                return
            }
            save(logService: logService, log: newLog, for: user)
                    .sink(receiveValue: { newAction in
                        send(newAction)
                    })
                    .store(in: &cancellables)
        default:
            break
        }
    }
}

private func save(logService: LogService, log: Loggable, for user: User) -> AnyPublisher<AppAction, Never> {
    return logService.save(log: log, for: user)
            .map { result in
                return AppAction.createLog(action: .onCreateLogSuccess)
            }.catch { (err) -> Just<AppAction> in
                return Just(AppAction.createLog(action: .onCreateLogFailure(error: err)))
            }
            .eraseToAnyPublisher()
}

private func createLogFromState(state: CreateLogState) -> Loggable? {
    let logId = UUID().uuidString
    let logDate = Date()
    switch state.selectedCategory {
    case .medication:
        guard let selectedMedication = state.medication.selectedMedication else {
            AppLogging.warn("Attempted to create medication log with no selected medication.")
            break
        }
        guard !state.medication.dosage.isEmptyWithoutWhitespace() else {
            AppLogging.warn("Attempted to create medication log with no dosage.")
            break
        }
        return MedicationLog(id: logId, dateCreated: logDate, notes: state.notes, medicationId: selectedMedication.id, dosage: state.medication.dosage)
    case .note:
        guard !state.notes.isEmptyWithoutWhitespace() else {
            AppLogging.warn("Attempted to create note log with empty notes.")
            break
        }
        return NoteLog(id: logId, dateCreated: logDate, notes: state.notes)
    default:
        break
    }
    return nil
}