//
//  RecentLogRow.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

extension DateFormatter {
    // Date + Time shown in log rows
    private static var logRowDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a, MMM d"
        return dateFormatter
    }
    static func stringForLogRowDate(from date: Date) -> String {
        return logRowDateFormatter.string(from: date)
    }
}

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
                        .font(Font.Theme.NormalText)
                        .foregroundColor(Color.Theme.Text)
                Text(self.viewModel.categoryName)
                        .lineLimit(1)
                        .font(Font.Theme.SmallText)
                        .foregroundColor(self.viewModel.categoryColor)
            }
            Spacer(minLength: CGFloat.Theme.Layout.RowSeparator)
            Text(self.viewModel.timeString)
                    .lineLimit(1)
                    .font(Font.Theme.SmallText)
                    .foregroundColor(Color.Theme.Primary)
        }
        .modifier(RowModifier())
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
