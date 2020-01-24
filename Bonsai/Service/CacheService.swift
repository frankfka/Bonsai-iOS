//
// Created by Frank Jia on 2020-01-23.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

protocol CacheService {
    func getLogSearchable(with id: String, in category: LogCategory) -> LogSearchable?
    func saveLogSearchable(_ item: LogSearchable)
}

// Cache object to be stored by the cache
class LogSearchableCacheObject {
    let wrappedItem: LogSearchable

    init(_ item: LogSearchable) {
        self.wrappedItem = item
    }
}

class CacheServiceImpl: CacheService {

    private let logSearchableCache: NSCache<NSString, LogSearchableCacheObject>

    init() {
        logSearchableCache = NSCache<NSString, LogSearchableCacheObject>()
    }

    func getLogSearchable(with id: String, in category: LogCategory) -> LogSearchable? {
        if let cached = self.logSearchableCache.object(forKey: getCacheIdForLogSearchable(logSearchableId: id, category: category)),
           cached.wrappedItem.parentCategory == category {
            return cached.wrappedItem
        }
        return nil
    }

    func saveLogSearchable(_ item: LogSearchable) {
        self.logSearchableCache.setObject(
                LogSearchableCacheObject(item),
                forKey: getCacheIdForLogSearchable(logSearchableId: item.id, category: item.parentCategory)
        )
    }

    private func getCacheIdForLogSearchable(logSearchableId: String, category: LogCategory) -> NSString {
        return NSString(string: "\(category.displayValue())-\(logSearchableId)")
    }

}