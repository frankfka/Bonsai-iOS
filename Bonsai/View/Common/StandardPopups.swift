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

        let image: Image
        switch type {
        case .success:
            image = Image.Icons.CheckmarkCircle
        case .failure:
            image = Image.Icons.XMarkCircle
        case .info:
            image = Image.Icons.InfoCircle
        }

        return self.withPopup(show: show) {
            VStack {
                image
                    .resizable()
                    .frame(
                        width: CGFloat.Theme.Font.PopupIcon,
                        height: CGFloat.Theme.Font.PopupIcon
                    )
                .foregroundColor(Color.Theme.Primary)
                .padding(.bottom, CGFloat.Theme.Layout.Small)
                if text != nil {
                    Text(text!)
                        .font(Font.Theme.NormalText)
                        .foregroundColor(Color.Theme.SecondaryText)
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
