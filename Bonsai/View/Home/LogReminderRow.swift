//
//  LogReminderRow.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-08.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogReminderRow: View {
    
    struct ViewModel: Identifiable {
        var title: String
        var subtitle: String
        var recurringTimestamp: String
        var isTimestampOverdue: Bool
        
        internal let id = UUID()
        
        init(title: String, subtitle: String, recurringTimestamp: String, overdue: Bool) {
            self.title = title
            self.subtitle = subtitle
            self.recurringTimestamp = recurringTimestamp
            self.isTimestampOverdue = overdue
        }
        
    }
    
    var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Image.Icons.todoEmpty
                .font(Font.Theme.normalIcon)
                .foregroundColor(Color.Theme.primary)
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(Font.Theme.boldNormalText)
                    .foregroundColor(Color.Theme.text)
                Text(viewModel.subtitle)
                    .font(Font.Theme.subtext)
                    .foregroundColor(Color.Theme.textLight)
            }
            .padding(.leading, CGFloat.Theme.Layout.normal)
            Spacer()
            HStack {
                Text(viewModel.recurringTimestamp)
                    .font(Font.Theme.subtext)
                    .padding(.trailing, CGFloat.Theme.Layout.small)
                    .foregroundColor(viewModel.isTimestampOverdue ? Color.Theme.accent : Color.Theme.primary)
            }
        }
        .padding(.vertical, CGFloat.Theme.Layout.small)
        .padding(.horizontal, CGFloat.Theme.Layout.normal)
        .background(Color.Theme.backgroundSecondary)
    }
}


struct LogReminderRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                LogReminderRow(viewModel: LogReminderRow.ViewModel.init(title: "Multivitamins", subtitle: "1 Capsule", recurringTimestamp: "8:00AM, Every Day", overdue: true))
            }
            .previewLayout(.sizeThatFits)
            .colorScheme(.light)
        }
    }
}
