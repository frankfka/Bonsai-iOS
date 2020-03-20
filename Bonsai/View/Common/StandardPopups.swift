//
// Created by Frank Jia on 2019-12-25.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import SwiftUI

private let showTimeSeconds = 1.5

enum PopupType {
    case success
    case failure
    case info
}

extension View {
    func withStandardPopup(show: Binding<Bool>, type: PopupType, text: String? = nil, onDisappear: VoidCallback? = nil) -> some View {

        let imageName: String
        switch type {
        case .success:
            imageName = "checkmark.circle"
        case .failure:
            imageName = "xmark.circle"
        case .info:
            imageName = "info.circle"
        }

        return self.withPopup(show: show) {
            VStack {
                Image(systemName: imageName)
                .resizable()
                .frame(
                    width: CGFloat.Theme.Font.popupIcon,
                    height: CGFloat.Theme.Font.popupIcon
                )
                .foregroundColor(Color.Theme.primary)
                .padding(.bottom, CGFloat.Theme.Layout.small)
                if text != nil {
                    Text(text!)
                        .font(Font.Theme.normalText)
                        .foregroundColor(Color.Theme.text)
                }
            }
            .onAppear() {
                ViewHelpers.toggleAfterDelay(delay: showTimeSeconds, binding: show) {
                    onDisappear?()
                }
            }
            .eraseToAnyView()
        }
    }
}