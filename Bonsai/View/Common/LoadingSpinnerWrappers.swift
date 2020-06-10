//
//  FullScreenLoadingSpinner.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-15.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

extension View {
    func withLoadingPopup(show: Binding<Bool>, text: String? = nil) -> some View {
        return self.withPopup(show: show) {
            VStack {
                LoadingSpinner(size: .small)
                    .padding(.bottom, CGFloat.Theme.Layout.Small)
                if text != nil {
                    Text(text!)
                        .font(Font.Theme.NormalText)
                        .foregroundColor(Color.Theme.SecondaryText)
                }
            }.eraseToAnyView()
        }
    }
}

struct FullScreenLoadingSpinner: View {
    private let size: LoadingSpinner.Size
    private let isOverlay: Bool
    
    init(size: LoadingSpinner.Size = .normal, isOverlay: Bool = true) {
        self.size = size
        self.isOverlay = isOverlay
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Spacer()
                FullWidthLoadingSpinner(size: self.size)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, alignment: .center)
            .background(self.isOverlay ? Color.Theme.Overlay : Color.Theme.BackgroundPrimary)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct FullWidthLoadingSpinner: View {
    private let size: LoadingSpinner.Size
    
    init(size: LoadingSpinner.Size = .normal) {
        self.size = size
    }
    
    var body: some View {
        HStack() {
            Spacer()
            LoadingSpinner(size: size)
            Spacer()
        }
    }
}

struct FullScreenLoadingSpinner_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenLoadingSpinner()
    }
}
