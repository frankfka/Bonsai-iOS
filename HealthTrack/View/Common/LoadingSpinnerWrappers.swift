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
                        .padding(.bottom, CGFloat.Theme.Layout.small)
                if text != nil {
                    Text(text!)
                            .font(Font.Theme.normalText)
                            .foregroundColor(Color.Theme.text)
                }
            }.eraseToAnyView()
        }
    }
}

struct FullScreenLoadingSpinner: View {
    private let size: LoadingSpinner.Size
    
    init(size: LoadingSpinner.Size = .normal) {
        self.size = size
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Spacer()
                FullWidthLoadingSpinner(size: self.size)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, alignment: .center)
            .background(Color.Theme.overlay)
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
