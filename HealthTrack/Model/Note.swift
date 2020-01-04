//
// Created by Frank Jia on 2020-01-03.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation

struct NoteLog: Loggable {
    let category: LogCategory = .note
    let id: String
    let title: String
    let dateCreated: Date
    let notes: String
}