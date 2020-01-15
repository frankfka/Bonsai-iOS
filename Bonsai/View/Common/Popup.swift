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
                    .padding(CGFloat.Theme.Layout.normal)
                    .frame(minWidth: CGFloat.Theme.Layout.popupFrameSize, minHeight: CGFloat.Theme.Layout.popupFrameSize)
                    .background(
                        RoundedRectangle(cornerRadius: CGFloat.Theme.Layout.cornerRadius)
                            .foregroundColor(Color.Theme.overlay)
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
