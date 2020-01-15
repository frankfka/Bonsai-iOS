//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Combine
import Foundation

struct CreateLogMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            createLogSearchMiddleware(logService: services.logService),
            createLogAddNewItemMiddleware(logService: services.logService),
            createLogOnSaveMiddleware(logService: services.logService)
        ]
    }

    private static func createLogSearchMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case let .createLog(action: .searchQueryDidChange(newQuery)):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when searching")
                }
                // Check new query is not empty
                guard !newQuery.isEmptyWithoutWhitespace() else {
                    doInMiddleware {
                        send(AppAction.createLog(action: .searchDidComplete(results: [])))
                    }
                    return
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

    private static func search(logService: LogService, with query: String, for user: User, in category: LogCategory) -> AnyPublisher<AppAction, Never> {
        return logService.search(with: query, by: user, in: category)
                .map { results in
                    return AppAction.createLog(action: .searchDidComplete(results: results))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.createLog(action: .searchDidComplete(results: [])))
                }
                .eraseToAnyPublisher()
    }

    private static func createLogAddNewItemMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case let .createLog(action: .onAddSearchItemPressed(name)):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when searching")
                }
                // Check new item is not empty
                guard !name.isEmptyWithoutWhitespace() else {
                    doInMiddleware {
                        send(AppAction.createLog(action: .onAddSearchItemFailure(error: AppError(message: "New item name is empty"))))
                    }
                    return
                }
                guard let newSearchItem = createSearchItemFromState(state: state.createLog, newItemName: name, user: user) else {
                    doInMiddleware {
                        send(.createLog(action: .onAddSearchItemFailure(error: AppError(message: "Could not make new search item"))))
                    }
                    return
                }
                // Perform save
                save(logService: logService, logItem: newSearchItem, for: user)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func save(logService: LogService, logItem: LogSearchable, for user: User) -> AnyPublisher<AppAction, Never> {
        return logService.save(logItem: logItem, for: user)
                .map {
                    return AppAction.createLog(action: .onAddSearchItemSuccess(addedItem: logItem))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.createLog(action: .onAddSearchItemFailure(error: err)))
                }
                .eraseToAnyPublisher()
    }

    private static func createSearchItemFromState(state: CreateLogState, newItemName: String, user: User) -> LogSearchable? {
        let itemId = UUID().uuidString
        let createdBy = user.id
        let itemName = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        switch state.selectedCategory {
        case .medication:
            return Medication(id: itemId, name: itemName, createdBy: createdBy)
        default:
            break
        }
        return nil
    }

    private static func createLogOnSaveMiddleware(logService: LogService) -> Middleware<AppState> {
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

    private static func save(logService: LogService, log: Loggable, for user: User) -> AnyPublisher<AppAction, Never> {
        return logService.save(log: log, for: user)
                .map { result in
                    return AppAction.createLog(action: .onCreateLogSuccess(newLog: log))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.createLog(action: .onCreateLogFailure(error: err)))
                }
                .eraseToAnyPublisher()
    }

    // Fetches state and creates the corresponding Loggable struct to save
    private static func createLogFromState(state: CreateLogState) -> Loggable? {
        let logId = UUID().uuidString
        let logDate = Date()
        let logNotes = state.notes
        switch state.selectedCategory {
        case .mood:
            guard let selectedMoodRankIndex = state.mood.selectedMoodRankIndex,
                  selectedMoodRankIndex < state.mood.allMoodRanks.count else {
                AppLogging.warn("Invalid mood rank selection to create a log.")
                break
            }
            let selectedMoodRank = state.mood.allMoodRanks[selectedMoodRankIndex]
            return MoodLog(
                    id: logId,
                    title: selectedMoodRank.description,
                    dateCreated: logDate,
                    notes: logNotes,
                    moodRank: selectedMoodRank
            )
        case .nutrition:
            guard let selectedNutrition = state.nutrition.selectedItem else {
                AppLogging.warn("Attempted to create a nutrition log with no selected nutrition item.")
                break
            }
            guard !state.nutrition.amount.isEmptyWithoutWhitespace() else {
                AppLogging.warn("Attempted to create a nutrition log with no amount.")
                break
            }
            return NutritionLog(
                    id: logId,
                    title: selectedNutrition.name,
                    dateCreated: logDate,
                    notes: logNotes,
                    nutritionItemId: selectedNutrition.id,
                    amount: state.nutrition.amount
            )
        case .medication:
            guard let selectedMedication = state.medication.selectedMedication else {
                AppLogging.warn("Attempted to create medication log with no selected medication.")
                break
            }
            guard !state.medication.dosage.isEmptyWithoutWhitespace() else {
                AppLogging.warn("Attempted to create medication log with no dosage.")
                break
            }
            return MedicationLog(
                    id: logId,
                    title: selectedMedication.name,
                    dateCreated: logDate,
                    notes: logNotes,
                    medicationId: selectedMedication.id,
                    dosage: state.medication.dosage
            )
        case .symptom:
            guard let selectedSymptom = state.symptom.selectedSymptom else {
                AppLogging.warn("Attempted to create symptom log with no selected symptom")
                break
            }
            return SymptomLog(
                    id: logId,
                    title: selectedSymptom.name,
                    dateCreated: logDate,
                    notes: logNotes,
                    symptomId: selectedSymptom.id,
                    severity: state.symptom.severity
            )
        case .activity:
            guard let selectedActivity = state.activity.selectedActivity else {
                AppLogging.warn("Attempted to create activity log with no selected activity")
                break
            }
            guard let activityDuration = state.activity.duration else {
                AppLogging.warn("Attempted to create activity log with no duration")
                break
            }
            return ActivityLog(
                    id: logId,
                    title: selectedActivity.name,
                    dateCreated: logDate,
                    notes: logNotes,
                    activityId: selectedActivity.id,
                    duration: activityDuration
            )
        case .note:
            guard !logNotes.isEmptyWithoutWhitespace() else {
                AppLogging.warn("Attempted to create note log with empty notes.")
                break
            }
            return NoteLog(
                    id: logId,
                    title: logNotes,
                    dateCreated: logDate,
                    notes: logNotes
            )
        }
        return nil
    }
}