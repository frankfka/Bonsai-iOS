//
// Created by Frank Jia on 2020-02-19.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI

// From https://github.com/AppPear/ChartView
extension CGPoint {
    static func getMidpoint(between p1: CGPoint, and p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    static func getControlPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        var midpoint = CGPoint.getMidpoint(between: p1, and: p2)
        let diffY = abs(p2.y - midpoint.y)

        if (p2.y > p1.y) {
            midpoint.y += diffY
        } else {
            midpoint.y -= diffY
        }
        return midpoint
    }
}