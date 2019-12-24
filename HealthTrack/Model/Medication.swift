//
//  Medication.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-14.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

struct Medication: LogSearchable {
    let id: String
    let name: String
    let parentCategory: LogCategory = .medication
    let createdBy: String
}
