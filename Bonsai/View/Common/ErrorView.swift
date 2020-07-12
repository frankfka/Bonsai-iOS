//
//  ErrorView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2020-01-12.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

// Generic full screen error view
struct FullScreenErrorView: View {
    private let onRetryTapped: VoidCallback?

    init(onRetryTapped: VoidCallback? = nil) {
        self.onRetryTapped = onRetryTapped
    }

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            GenericErrorView(onRetryTapped: self.onRetryTapped)
            Spacer()
        }
    }
}

struct GenericErrorView: View {
    private let onRetryTapped: VoidCallback?
    private var retryButtonViewModel: RoundedButtonView.ViewModel {
        RoundedButtonView.ViewModel(
            text: "Try Again",
            textColor: Color.white,
            fillColor: Color.Theme.Primary,
            onTap: self.onRetryTapped
        )
    }

    init(onRetryTapped: VoidCallback? = nil) {
        self.onRetryTapped = onRetryTapped
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: CGFloat.Theme.Layout.Normal) {
                Image.Icons.XMarkCircle
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(maxWidth: geometry.size.width / 4, alignment: .center)
                    .foregroundColor(Color.Theme.Primary)
                Text("Something isn't Right")
                    .font(Font.Theme.Heading)
                    .foregroundColor(Color.Theme.Text)
                Text("Check your internet connection and try again.")
                    .multilineTextAlignment(.center)
                    .font(Font.Theme.NormalText)
                    .foregroundColor(Color.Theme.SecondaryText)
                if self.onRetryTapped != nil {
                    RoundedButtonView(vm: self.retryButtonViewModel)
                }
            }.padding(CGFloat.Theme.Layout.Normal)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GenericErrorView()
                .frame(height: 300)
                .previewLayout(.sizeThatFits)
            GenericErrorView(onRetryTapped: {})
                .frame(height: 300)
                .previewLayout(.sizeThatFits)
            FullScreenErrorView()
        }
        .background(Color.white)
        .padding()
        .background(Color.gray)
    }
}
