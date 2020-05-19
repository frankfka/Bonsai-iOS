//
//  LogReminderRow.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-08.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

extension DateFormatter {
    // Date + Time shown in log reminder rows
    private static var logReminderRowDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a, MMM d"
        return dateFormatter
    }
    static func stringForLogReminderRowDate(from date: Date) -> String {
        return logReminderRowDateFormatter.string(from: date)
    }
}

struct LogReminderRow: View {
    
    struct ViewModel: Identifiable {
        let title: String
        let reminderDate: String
        let isOverdue: Bool
        let categoryName: String
        let categoryColor: Color
        let onTodoTapped: VoidCallback?
        let onRowTapped: VoidCallback?
        
        internal let id = UUID()
        
        init(logReminder: LogReminder, onTodoTapped: VoidCallback? = nil, onRowTapped: VoidCallback? = nil) {
            self.title = logReminder.templateLoggable.title
            self.reminderDate = DateFormatter.stringForLogReminderRowDate(from: logReminder.reminderDate)
            self.isOverdue = logReminder.isOverdue
            self.categoryName = logReminder.templateLoggable.category.displayValue()
            self.categoryColor = logReminder.templateLoggable.category.displayColor()
            self.onTodoTapped = onTodoTapped
            self.onRowTapped = onRowTapped
        }
        
    }
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Image.Icons.todoEmpty
                .font(Font.Theme.normalIcon)
                .foregroundColor(Color.Theme.primary)
                // Add additional padding to make tappable space bigger
                .padding(.vertical, CGFloat.Theme.Layout.small)
                .padding(.trailing, CGFloat.Theme.Layout.small)
                .onTapGesture {
                    self.viewModel.onTodoTapped?()
                }
            HStack {
                VStack(alignment: .leading) {
                    Text(self.viewModel.title)
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
                Text(viewModel.reminderDate)
                        .font(Font.Theme.subtext)
                        .foregroundColor(viewModel.isOverdue ? Color.Theme.accent : Color.Theme.primary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                self.viewModel.onRowTapped?()
            }
        }
        .modifier(RowModifier())
    }
}


struct LogReminderRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                LogReminderRow(viewModel: LogReminderRow.ViewModel(logReminder: PreviewLogReminders.overdue))
                LogReminderRow(viewModel: LogReminderRow.ViewModel(logReminder: PreviewLogReminders.notOverdue))
            }
            .previewLayout(.sizeThatFits)
            .colorScheme(.light)
        }
    }
}
