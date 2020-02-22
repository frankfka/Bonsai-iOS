//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    func isEmptyWithoutWhitespace() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension TimeInterval {
    static let hour: TimeInterval = TimeInterval(3600)
    static let day: TimeInterval = TimeInterval(86400)
}