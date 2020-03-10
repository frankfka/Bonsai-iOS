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
typealias DoubleCallback = (Double) -> ()
typealias StringCallback = (String) -> ()
typealias DateCallback = (Date) -> ()
typealias TimeIntervalCallback = (TimeInterval) -> ()

struct ViewHelpers {
    
    static func toggleWithAnimation(binding: Binding<Bool>) {
        withAnimation(Animation.easeInOut(duration: 0.25)) {
            binding.wrappedValue.toggle()
        }
    }

    static func toggleAfterDelay(delay: Double, binding: Binding<Bool>, onToggle: @escaping VoidCallback) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            binding.wrappedValue.toggle()
            onToggle()
        }
    }
    
}

extension View {
    // https://swiftwithmajid.com/2019/12/04/must-have-swiftui-extensions/
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    func embedInNavigationView() -> some View {
        NavigationView { self }
    }
}

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

extension UIApplication {
    // https://inneka.com/programming/swift/how-to-hide-keyboard-when-using-swiftui/
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
