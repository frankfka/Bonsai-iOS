//
//  RecentLogRow.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogRow: View {
    
    struct ViewModel: Identifiable {
        var id: String {
            loggable.id
        }
        let loggable: Loggable
        let categoryName: String
        let categoryColor: Color
        let logName: String
        let timeString: String

        init(loggable: Loggable) {
            self.loggable = loggable
            self.categoryName = loggable.category.displayValue()
            self.categoryColor = loggable.category.displayColor()
            self.logName = loggable.title
            self.timeString = DateFormatter.stringForLogRowDate(from: loggable.dateCreated)
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.viewModel.logName)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(Font.Theme.normalText)
                        .foregroundColor(Color.Theme.textDark)
                Text(self.viewModel.categoryName)
                        .lineLimit(1)
                        .font(Font.Theme.subtext)
                        .foregroundColor(self.viewModel.categoryColor)
            }
            Spacer(minLength: CGFloat.Theme.Layout.rowSeparator)
            Text(self.viewModel.timeString)
                    .lineLimit(1)
                    .font(Font.Theme.subtext)
                    .foregroundColor(Color.Theme.primary)
        }
        .padding(.vertical, CGFloat.Theme.Layout.small)
        .padding(.horizontal, CGFloat.Theme.Layout.normal)
        .contentShape(Rectangle())
    }
}

struct LogRow_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            LogRow(viewModel: LogRow.ViewModel(loggable: PreviewLoggables.medication))
            LogRow(viewModel: LogRow.ViewModel(loggable: PreviewLoggables.notes))
        }.previewLayout(.sizeThatFits)
    }
}
