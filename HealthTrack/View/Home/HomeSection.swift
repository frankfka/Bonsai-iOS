//
//  HomeSection.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-15.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

// TODO: Create a viewbuilder from these
struct HomeSectionWrapper: View {
    let sectionTitle: String
    let sectionView: AnyView
    init(sectionView: AnyView, sectionTitle: String) {
        self.sectionTitle = sectionTitle
        self.sectionView = sectionView
    }
    
    var body: some View {
        Section(header: HomeSectionTitle(text: sectionTitle)) {
            sectionView
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
