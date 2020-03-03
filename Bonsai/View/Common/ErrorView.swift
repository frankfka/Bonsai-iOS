//
//  ErrorView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2020-01-12.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

// TODO: Allow for retries
struct ErrorView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: CGFloat.Theme.Layout.normal) {
                Spacer()
                Image(systemName: "xmark.circle")
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(maxWidth: geometry.size.width / 4, alignment: .center)
                    .foregroundColor(Color.Theme.primary)
                Text("Something isn't Right")
                    .font(Font.Theme.heading)
                    .foregroundColor(Color.Theme.textDark)
                Text("Check your internet connection and try again.")
                    .multilineTextAlignment(.center)
                    .font(Font.Theme.normalText)
                    .foregroundColor(Color.Theme.text)
                Spacer()
            }.padding(CGFloat.Theme.Layout.normal * 3)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ErrorView()
                .frame(height: 300)
                .previewLayout(.sizeThatFits)
            ErrorView()
        }
    }
}
