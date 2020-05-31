//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Combine
import Foundation

struct CreateLogMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            initFromReminderMiddleware(logService: services.logService),
            createLogSearchMiddleware(logService: services.logService),
            createLogAddNewItemMiddleware(logService: services.logService),
            createLogOnSaveMiddleware(logService: services.logService),
            completeLogReminderMiddleware(logReminderService: services.logReminderService, notificationService: services.notificationService)
        ]
    }

    // MARK: Init from Reminder
    private static func initFromReminderMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case let .createLog(action: .beginInitFromLogReminder(logReminder)):
                initLoggableForReminder(logService: logService, reminder: logReminder)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func initLoggableForReminder(logService: LogService, reminder: LogReminder) -> AnyPublisher<AppAction, Never> {
        return logService.initLogDetails(for: reminder.templateLoggable)
                .map { initializedLoggable in
                    var newReminder = reminder
                    newReminder.templateLoggable = initializedLoggable
                    return AppAction.createLog(action: .completedInitFromLogReminder(logReminder: newReminder))
                }.catch { (err) -> Just<AppAction> in
                    AppLogging.error("Error initializing loggable for log reminder: \(err)")
                    return Just(AppAction.createLog(action: .completedInitFromLogReminder(logReminder: reminder)))
                }
                .eraseToAnyPublisher()
    }

    // MARK: Log Item Search
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
                    send(AppAction.createLog(action: .searchDidComplete(results: [])))
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
        return logService.searchLogSearchables(with: query, by: user, in: category)
                .map { results in
                    return AppAction.createLog(action: .searchDidComplete(results: results))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.createLog(action: .searchDidComplete(results: [])))
                }
                .eraseToAnyPublisher()
    }

    // MARK: Add Log Item
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
                    send(AppAction.createLog(action: .onAddSearchItemFailure(error: ServiceError(message: "New item name is empty"))))
                    return
                }
                guard let newSearchItem = createSearchItemFromState(state: state.createLog, newItemName: name, user: user) else {
                    send(.createLog(action: .onAddSearchItemFailure(error: ServiceError(message: "Could not make new search item"))))
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
        return logService.saveLogSearchable(logItem: logItem, for: user)
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
        case .nutrition:
            return NutritionItem(id: itemId, name: itemName, createdBy: createdBy)
        case .activity:
            return Activity(id: itemId, name: itemName, createdBy: createdBy)
        case .symptom:
            return Symptom(id: itemId, name: itemName, createdBy: createdBy)
        default:
            break
        }
        return nil
    }

    // MARK: Save Log
    private static func createLogOnSaveMiddleware(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .createLog(action: .onSavePressed):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when searching")
                }
                // Check that the log state is valid
                guard let newLog = createLogFromState(state: state.createLog) else {
                    send(.createLog(action: .onSaveFailure(error: ServiceError(message: "Could not parse log state"))))
                    return
                }
                save(logService: logService, log: newLog, for: user, with: state.createLog.associatedReminder)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func save(logService: LogService, log: Loggable, for user: User,
                             with associatedReminder: LogReminder?) -> AnyPublisher<AppAction, Never> {
        return logService.saveLog(log: log, for: user)
                .map { result in
                    return AppAction.createLog(action: .onSaveSuccess(newLog: log, associatedLogReminder: associatedReminder))
                }.catch { (err) -> Just<AppAction> in
                    return Just(AppAction.createLog(action: .onSaveFailure(error: err)))
                }
                .eraseToAnyPublisher()
    }

    // Middleware to complete log reminder if needed
    private static func completeLogReminderMiddleware(logReminderService: LogReminderService,
                                                      notificationService: NotificationService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .createLog(action: let .onSaveSuccess(_, associatedLogReminder)):
                if let reminder = associatedLogReminder {
                    completeLogReminder(
                        logReminderService: logReminderService,
                        notificationService: notificationService,
                        logReminder: reminder
                    )
                            .sink(receiveValue: { newAction in
                                send(newAction)
                            })
                            .store(in: &cancellables)
                }
            default:
                break
            }
        }
    }

    private static func completeLogReminder(logReminderService: LogReminderService,
                                            notificationService: NotificationService,
                                            logReminder: LogReminder) -> AnyPublisher<AppAction, Never> {
        let completeResult = logReminderService.completeLogReminder(logReminder: logReminder)
        return completeResult
                .publisher
                .map { updatedReminder in
                    // Success - Remove associated notifications
                    notificationService.removeNotifications(for: [updatedReminder])
                    return AppAction.createLog(
                        action: .onLogReminderComplete(logReminder: updatedReminder, didDelete: completeResult.didDelete)
                    )
                }.catch { (err) -> Empty<AppAction, Never> in
                    AppLogging.error("Error completing log reminder: \(err)")
                    return Empty<AppAction, Never>()
                }.eraseToAnyPublisher()
    }

    // Fetches state and creates the corresponding Loggable struct to save
    private static func createLogFromState(state: CreateLogState) -> Loggable? {
        let logId = UUID().uuidString
        let logNotes = state.notes
        let logDate = state.date
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
                    amount: state.nutrition.amount,
                    selectedNutritionItem: selectedNutrition
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
                    dosage: state.medication.dosage,
                    selectedMedication: selectedMedication
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
                    severity: state.symptom.severity,
                    selectedSymptom: selectedSymptom
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
                    duration: activityDuration,
                    selectedActivity: selectedActivity
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
