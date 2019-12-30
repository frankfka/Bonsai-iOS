//
//  HomeSection.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-15.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct HomeSectionWrapper<Content>: View where Content: View {

    let sectionTitle: String
    let sectionView: () -> Content

    init(sectionTitle: String, sectionView: @escaping () -> Content) {
        self.sectionView = sectionView
        self.sectionTitle = sectionTitle
    }

    var body: some View {
        Section(header: HomeSectionTitle(text: sectionTitle)) {
            sectionView()
                    .modifier(RoundedBorderSection())
        }
    }
}

struct HomeSectionTitle: View {
    let titleText: String
    init(text: String) {
        titleText = text
    }
    var body: some View {
        Text(titleText)
            .font(Font.Theme.heading)
                .foregroundColor(Color.Theme.textDark)
            .padding(.all, CGFloat.Theme.Layout.small)
    }
}
