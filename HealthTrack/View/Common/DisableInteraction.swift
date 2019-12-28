//
// Created by Frank Jia on 2019-12-25.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import SwiftUI

// Simple view that disables interaction on underlying views
struct AbsorbTouch<Content>: View where Content: View {

    @Binding var disableInteraction: Bool
    let presentingView: () -> Content

    init(show: Binding<Bool>, presentingView: @escaping () -> Content) {
        self._disableInteraction = show
        self.presentingView = presentingView
    }

    var body: some View {
        ZStack {
            self.presentingView()
            if self.disableInteraction {
                // TODO: This is a hack, but we get AttributeGraph weirdness if we just use `.disabled()`
                Rectangle()
                        .allowsHitTesting(true)
                        .foregroundColor(Color.Theme.backgroundPrimary)
                        .opacity(0.05)
            }
        }
    }
}

extension View {
    func disableInteraction(isDisabled: Binding<Bool>) -> some View {
        AbsorbTouch(
                show: isDisabled,
                presentingView: { self.eraseToAnyView() }
        )
    }
}
