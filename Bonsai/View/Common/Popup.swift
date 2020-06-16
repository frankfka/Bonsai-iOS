//
// Created by Frank Jia on 2019-12-25.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct Popup<Content>: View where Content: View {
    
    @Binding var showPopup: Bool
    let presentingView: () -> Content
    let content: () -> Content
    
    init(show: Binding<Bool>, presentingView: @escaping () -> Content, content: @escaping () -> Content) {
        self._showPopup = show
        self.presentingView = presentingView
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            self.presentingView()
            if self.showPopup {
                self.content()
                    .padding(CGFloat.Theme.Layout.Normal)
                    .frame(minWidth: CGFloat.Theme.Layout.PopupFrameSize, minHeight: CGFloat.Theme.Layout.PopupFrameSize)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: CGFloat.Theme.Layout.CornerRadius)
                                    .foregroundColor(Color.Theme.BackgroundPopup)
                            RoundedRectangle(cornerRadius: CGFloat.Theme.Layout.CornerRadius)
                                    .stroke(Color.Theme.GrayscaleSecondary, lineWidth: 0.5)
                        }
                    )
            }
        }
    }
}

extension View {
    func withPopup(show: Binding<Bool>, content: @escaping () -> AnyView) -> some View {
        Popup(
            show: show,
            presentingView: { self.eraseToAnyView() },
            content: content
        )
    }
}
