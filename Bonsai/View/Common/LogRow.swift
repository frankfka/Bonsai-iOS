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
        let id: String
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

    private static var medicationLogVm: LogRow.ViewModel = LogRow.ViewModel(
            id: "",
            categoryName: LogCategory.medication.displayValue(),
            categoryColor: LogCategory.medication.displayColor(),
            logName: "Advil",
            timeString: "Jan 1, 2020"
    )
    
    private static var noteLogVm: LogRow.ViewModel = LogRow.ViewModel(
            id: "",
            categoryName: LogCategory.note.displayValue(),
            categoryColor: LogCategory.note.displayColor(),
            logName: "This is a Long Testing Note Testing Testing Test",
            timeString: "Jan 1, 2020"
    )

    static var previews: some View {
        Group {
            LogRow(viewModel: medicationLogVm)
            LogRow(viewModel: noteLogVm)
        }.previewLayout(.sizeThatFits)
    }
}
