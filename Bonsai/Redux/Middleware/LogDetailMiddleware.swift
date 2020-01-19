//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import Combine

struct LogDetailMiddleware {

    static func middleware(services: Services) -> [Middleware<AppState>] {
        return [
            initLogData(logService: services.logService),
            deleteLog(logService: services.logService)
        ]
    }

    private static func initLogData(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .logDetails(action: .initState(let initialLoggable)):
                // Check that we need to fetch data
                if initialLoggable.category == .medication && (initialLoggable as? MedicationLog)?.selectedMedication == nil ||
                           initialLoggable.category == .symptom && (initialLoggable as? SymptomLog)?.selectedSymptom == nil ||
                           initialLoggable.category == .nutrition && (initialLoggable as? NutritionLog)?.selectedNutritionItem == nil ||
                           initialLoggable.category == .activity && (initialLoggable as? ActivityLog)?.selectedActivity == nil {
                    // We're missing the selected log searchable item, so need to fetch
                    initLogData(for: initialLoggable, logService: logService)
                            .sink(receiveValue: { newAction in
                                send(newAction)
                            })
                            .store(in: &cancellables)
                } else {
                    // No fetch needed
                    doInMiddleware {
                        send(.logDetails(action: .fetchLogDataSuccess(loggable: initialLoggable)))
                    }
                }
            default:
                break
            }
        }
    }

    // Slightly messy way of doing things
    private static func initLogData(for loggable: Loggable, logService: LogService) -> AnyPublisher<AppAction, Never> {
        // Only process certain categories, and if the associated item is nil
        var mappedPublisher: Publishers.Map<AnyPublisher<LogSearchable, ServiceError>, AppAction>? = nil
        switch loggable.category {
        case .medication:
            if let loggable = loggable as? MedicationLog {
                mappedPublisher = logService.getLogSearchable(with: loggable.medicationId, in: .medication)
                        .map { logSearchable -> AppAction in
                            var newLoggable = loggable
                            if let logSearchable = logSearchable as? Medication {
                                newLoggable.selectedMedication = logSearchable
                                return AppAction.logDetails(action: .fetchLogDataSuccess(loggable: newLoggable))
                            } else {
                                return AppAction.logDetails(action: .fetchLogDataError(error: ServiceError(message: "Returned log searchable is not a medication")))
                            }
                        }
            }
        case .symptom:
            if let loggable = loggable as? SymptomLog {
                mappedPublisher = logService.getLogSearchable(with: loggable.symptomId, in: .symptom)
                        .map { logSearchable -> AppAction in
                            var newLoggable = loggable
                            if let logSearchable = logSearchable as? Symptom {
                                newLoggable.selectedSymptom = logSearchable
                                return AppAction.logDetails(action: .fetchLogDataSuccess(loggable: newLoggable))
                            } else {
                                return AppAction.logDetails(action: .fetchLogDataError(error: ServiceError(message: "Returned log searchable is not a symptom")))
                            }
                        }
            }
        case .nutrition:
            if let loggable = loggable as? NutritionLog {
                mappedPublisher = logService.getLogSearchable(with: loggable.nutritionItemId, in: .nutrition)
                        .map { logSearchable -> AppAction in
                            var newLoggable = loggable
                            if let logSearchable = logSearchable as? NutritionItem {
                                newLoggable.selectedNutritionItem = logSearchable
                                return AppAction.logDetails(action: .fetchLogDataSuccess(loggable: newLoggable))
                            } else {
                                return AppAction.logDetails(action: .fetchLogDataError(error: ServiceError(message: "Returned log searchable is not a nutrition item")))
                            }
                        }
            }
        case .activity:
            if let loggable = loggable as? ActivityLog {
                mappedPublisher = logService.getLogSearchable(with: loggable.activityId, in: .activity)
                        .map { logSearchable -> AppAction in
                            var newLoggable = loggable
                            if let logSearchable = logSearchable as? Activity {
                                newLoggable.selectedActivity = logSearchable
                                return AppAction.logDetails(action: .fetchLogDataSuccess(loggable: newLoggable))
                            } else {
                                return AppAction.logDetails(action: .fetchLogDataError(error: ServiceError(message: "Returned log searchable is not an activity")))
                            }
                        }
            }
        default:
            break
        }
        // Return the processing result if we've processed
        if let mappedPublisher = mappedPublisher {
            return mappedPublisher
                    .catch { (err) -> Just<AppAction> in
                        Just(AppAction.logDetails(action: .fetchLogDataError(error: err)))
                    }
                    .eraseToAnyPublisher()
        }
        AppLogging.warn("Returning empty publisher in retrieving log detail data. This shouldn't be called. Investigate!")
        return Empty<AppAction, Never>().eraseToAnyPublisher()
    }

    private static func deleteLog(logService: LogService) -> Middleware<AppState> {
        return { state, action, cancellables, send in
            switch action {
            case .logDetails(action: .deleteCurrentLog):
                // Check user exists
                guard let user = state.global.user else {
                    fatalError("No user initialized when attempting to delete a log")
                }
                guard let logId = state.logDetails.loggable?.id else {
                    doInMiddleware {
                        send(.logDetails(action: .deleteError(error: ServiceError(message: "No loggable initialized in log details state, so cannot delete the log"))))
                    }
                    return
                }
                deleteLog(for: user, with: logId, logService: logService)
                        .sink(receiveValue: { newAction in
                            send(newAction)
                        })
                        .store(in: &cancellables)
            default:
                break
            }
        }
    }

    private static func deleteLog(for user: User, with id: String, logService: LogService) -> AnyPublisher<AppAction, Never> {
        return logService.deleteLog(with: id, for: user)
                .map {
                    AppLogging.info("Success deleting log \(id) for user \(user.id)")
                    return AppAction.logDetails(action: .deleteSuccess(deletedId: id))
                }.catch({ (err) -> Just<AppAction> in
                    AppLogging.info("Failed to delete log \(id) for user \(user.id): \(err)")
                    return Just(AppAction.logDetails(action: .deleteError(error: err)))
                }).eraseToAnyPublisher()
    }

}
