//
// Created by Frank Jia on 2020-03-12.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import SwiftUI

struct RoundedBorderSectionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.all, CGFloat.Theme.Layout.Small)
            .background(
                RoundedRectangle(cornerRadius: CGFloat.Theme.Layout.CornerRadius)
                    .foregroundColor(Color.Theme.BackgroundSecondary)
            )
    }
}

struct FormRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .padding(CGFloat.Theme.Layout.Normal)
            .background(Color.Theme.BackgroundSecondary)
    }
}

struct RowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, CGFloat.Theme.Layout.Small)
            .padding(.horizontal, CGFloat.Theme.Layout.Normal)
            .contentShape(Rectangle())
            .background(Color.Theme.BackgroundSecondary)
    }
}
