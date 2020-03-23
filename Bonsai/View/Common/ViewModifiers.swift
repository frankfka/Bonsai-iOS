//
// Created by Frank Jia on 2020-03-12.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import Foundation
import SwiftUI

struct RoundedBorderSectionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
                .padding(.all, CGFloat.Theme.Layout.small)
                .background(
                        RoundedRectangle(cornerRadius: CGFloat.Theme.Layout.cornerRadius)
                                .foregroundColor(Color.Theme.backgroundSecondary)
                )
    }
}

struct FormRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .padding(CGFloat.Theme.Layout.normal)
            .background(Color.Theme.backgroundSecondary)
    }
}

struct RowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
                .padding(.vertical, CGFloat.Theme.Layout.small)
                .padding(.horizontal, CGFloat.Theme.Layout.normal)
                .contentShape(Rectangle())
                .background(Color.Theme.backgroundSecondary)
    }
}
