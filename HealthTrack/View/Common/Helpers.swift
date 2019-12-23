//
//  Helpers.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-15.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import SwiftUI

typealias VoidCallback = () -> ()
typealias IntCallback = (Int) -> ()
typealias StringCallback = (String) -> ()

struct ViewHelpers {
    
    static func toggleWithAnimation(binding: Binding<Bool>) {
        withAnimation(Animation.easeInOut(duration: 0.25)) {
            binding.wrappedValue.toggle()
        }
    }
    
}

struct RoundedBorderSection: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.all, CGFloat.Theme.Layout.small)
            .background(
                RoundedRectangle(cornerRadius: CGFloat.Theme.Layout.cornerRadius)
                    .foregroundColor(Color.Theme.backgroundSecondary)
        )
    }
}
