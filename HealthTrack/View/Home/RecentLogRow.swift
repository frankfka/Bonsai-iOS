//
//  RecentLogRow.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct RecentLogRow: View {
    
    struct ViewModel: Identifiable {
        internal let id: String
        let categoryName: String
        let categoryColor: Color
        let logName: String
        let timeString: String

        init(id: String, categoryName: String, categoryColor: Color, logName: String, timeString: String) {
            self.id = id
            self.categoryName = categoryName
            self.categoryColor = categoryColor
            self.logName = logName
            self.timeString = timeString
        }
    }
    
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        // TODO: Preview to play with frames
        // TODO: String formatting for time
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.logName)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(Font.Theme.normalText)
                    .foregroundColor(Color.Theme.textDark)
                Text(viewModel.categoryName)
                    .lineLimit(1)
                    .font(Font.Theme.subtext)
                    .foregroundColor(viewModel.categoryColor)
            }
            // TODO: Put this in the other places
            Spacer(minLength: CGFloat.Theme.Layout.small)
            Text(viewModel.timeString)
                .lineLimit(1)
                .font(Font.Theme.subtext)
                .foregroundColor(Color.Theme.primary)
        }
        .padding(.vertical, CGFloat.Theme.Layout.small)
        .padding(.horizontal, CGFloat.Theme.Layout.normal)
    }
}
