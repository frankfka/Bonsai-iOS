//
// Created by Frank Jia on 2020-05-19.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI

typealias SwipeCallback = (ViewLogsTabSwipeGestureRecognizer.Direction) -> ()

// Recognizes a swipe on a view and determines direction
struct ViewLogsTabSwipeGestureRecognizer: ViewModifier {
    private static let MinXMagnitude: CGFloat = 100
    private static let MaxYMagnitude: CGFloat = 30

    enum Direction {
        case left
        case right
    }

    private let onSwipe: SwipeCallback

    init(onSwipe: @escaping SwipeCallback) {
        self.onSwipe = onSwipe
    }

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        let xMag = gesture.translation.width
                        if abs(xMag) > ViewLogsTabSwipeGestureRecognizer.MinXMagnitude &&
                                abs(gesture.translation.height) < ViewLogsTabSwipeGestureRecognizer.MaxYMagnitude {
                            // Valid gesture
                            self.onSwipe(xMag > 0 ? .right : .left)
                        }
                    }
            )
    }
}
