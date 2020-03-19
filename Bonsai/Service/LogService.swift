//
// Created by Frank Jia on 2019-12-14.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import Combine

protocol LogService {
    // CRUD on logs
    func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?,
                 limitedTo: Int?, startingAfterLog: Loggable?, offline: Bool) -> ServicePublisher<[Loggable]>
    func saveLog(log: Loggable, for user: User) -> ServicePublisher<Void>
    func deleteLog(with id: String, for user: User) -> ServicePublisher<Void>
    func initLogDetails(for loggable: Loggable) -> ServicePublisher<Loggable> // This populates (if needed) the associated LogSearchable
    // CRUD on log items (medications, nutrition, etc.)
    func getLogSearchable(with id: String, in category: LogCategory) -> ServicePublisher<LogSearchable>
    func searchLogSearchables(with query: String, by user: User, in category: LogCategory) -> ServicePublisher<[LogSearchable]>
    func saveLogSearchable(logItem: LogSearchable, for user: User) -> ServicePublisher<Void>
}

class LogServiceImpl: LogService {
    private let db: DatabaseService
    private let cache: CacheService

    init(db: DatabaseService, cache: CacheService) {
        self.db = db
        self.cache = cache
    }

    func getLogs(for user: User, in category: LogCategory?, since beginDate: Date?, toAndIncluding endDate: Date?,
                 limitedTo: Int?, startingAfterLog: Loggable?, offline: Bool) -> ServicePublisher<[Loggable]> {
        return self.db.getLogs(for: user, in: category, since: beginDate,
                toAndIncluding: endDate, limit: limitedTo, startingAfterLog: startingAfterLog, offline: offline)
    }

    func initLogDetails(for loggable: Loggable) -> ServicePublisher<Loggable> {
        // Default to the loggable itself
        let inputLoggablePublisher: ServicePublisher<Loggable> = ServiceFuture<Loggable> { promise in
            promise(.success(loggable))
        }.eraseToAnyPublisher()
        // Publisher for retrieving log searchable
        var initializedLogPublisher: AnyPublisher<Loggable, Error>? = nil
        var initErr: ServiceError? = nil
        // Process depending on category
        switch loggable.category {
                // Loggables that do not need to be initialized
        case .note:
            return inputLoggablePublisher
        case .mood:
            return inputLoggablePublisher
                // Loggables that need additional initialization
        case .medication:
            if var loggable = loggable as? MedicationLog {
                if loggable.selectedMedication != nil {
                    return inputLoggablePublisher
                }
                initializedLogPublisher = self.getLogSearchable(with: loggable.medicationId, in: .medication)
                        .tryMap { logSearchable -> Loggable in
                            if let logSearchable = logSearchable as? Medication {
                                loggable.selectedMedication = logSearchable
                                return loggable
                            } else {
                                throw ServiceError(message: "Returned log searchable does not match category")
                            }
                        }.eraseToAnyPublisher()
            } else {
                initErr = ServiceError(message: "Loggable is not medication log, could not init log details")
            }
        case .symptom:
            if var loggable = loggable as? SymptomLog {
                if loggable.selectedSymptom != nil {
                    return inputLoggablePublisher
                }
                initializedLogPublisher = self.getLogSearchable(with: loggable.symptomId, in: .symptom)
                        .tryMap { logSearchable -> Loggable in
                            if let logSearchable = logSearchable as? Symptom {
                                loggable.selectedSymptom = logSearchable
                                return loggable
                            } else {
                                throw ServiceError(message: "Returned log searchable does not match category")
                            }
                        }.eraseToAnyPublisher()
            } else {
                initErr = ServiceError(message: "Loggable is not symptom log, could not init log details")
            }
        case .nutrition:
            if var loggable = loggable as? NutritionLog {
                if loggable.selectedNutritionItem != nil {
                    return inputLoggablePublisher
                }
                initializedLogPublisher = self.getLogSearchable(with: loggable.nutritionItemId, in: .nutrition)
                        .tryMap { logSearchable -> Loggable in
                            if let logSearchable = logSearchable as? NutritionItem {
                                loggable.selectedNutritionItem = logSearchable
                                return loggable
                            } else {
                                throw ServiceError(message: "Returned log searchable does not match category")
                            }
                        }.eraseToAnyPublisher()

            } else {
                initErr = ServiceError(message: "Loggable is not nutrition log, could not init log details")
            }
        case .activity:
            if var loggable = loggable as? ActivityLog {
                if loggable.selectedActivity != nil {
                    return inputLoggablePublisher
                }
                initializedLogPublisher = self.getLogSearchable(with: loggable.activityId, in: .activity)
                        .tryMap { logSearchable -> Loggable in
                            if let logSearchable = logSearchable as? Activity {
                                loggable.selectedActivity = logSearchable
                                return loggable
                            } else {
                                throw ServiceError(message: "Returned log searchable does not match category")
                            }
                        }.eraseToAnyPublisher()
            } else {
                initErr = ServiceError(message: "Loggable is not activity log, could not init log details")
            }
        }
        if let resultPublisher = initializedLogPublisher {
            return resultPublisher.mapError { (err) -> ServiceError in
                if let err = err as? ServiceError {
                    return err
                }
                return ServiceError(message: "Error initializing log details", wrappedError: err)
            }.eraseToAnyPublisher()
        }
        // Error condition
        return ServiceFuture<Loggable> { promise in
            promise(.failure(ServiceError(message: "Error initializing log details, no publisher was created", wrappedError: initErr)))
        }.eraseToAnyPublisher()
    }

    func saveLogSearchable(logItem: LogSearchable, for user: User) -> ServicePublisher<Void> {
        return self.db.saveLogSearchable(logItem: logItem, for: user)
    }

    func saveLog(log: Loggable, for user: User) -> ServicePublisher<Void> {
        return self.db.saveOrUpdateLog(log: log, for: user)
    }


    func deleteLog(with id: String, for user: User) -> ServicePublisher<Void> {
        return self.db.deleteLog(for: user, with: id)
    }

    func getLogSearchable(with id: String, in category: LogCategory) -> ServicePublisher<LogSearchable> {
        if let cached = self.cache.getLogSearchable(with: id, in: category) {
            AppLogging.debug("Returning cached log searchable \(id)")
            return AnyPublisher(Just(cached).setFailureType(to: ServiceError.self))
        }
        return self.db.getLogSearchable(with: id, in: category).map { result -> LogSearchable in
            self.cache.saveLogSearchable(result)
            return result
        }.eraseToAnyPublisher()
    }

    func searchLogSearchables(with query: String, by user: User, in category: LogCategory) -> ServicePublisher<[LogSearchable]> {
        return self.db.searchLogSearchables(query: query, by: user, in: category)
    }

}
