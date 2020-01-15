//
//  LogReminderSection.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-08.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogReminderSection: View {
    
    struct ViewModel {
        let reminders: [LogReminderRow.ViewModel]
    }
    
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(viewModel.reminders) { reminder in
            LogReminderRow(viewModel: reminder)
        }
        .listStyle(GroupedListStyle())
    }
}

struct LogReminderSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LogReminderSection(viewModel: LogReminderSection.ViewModel(reminders: [
                LogReminderRow.ViewModel.init(title: "Multivitamins", subtitle: "1 Capsule", recurringTimestamp: "8:00AM, Every Day", overdue: true),
                LogReminderRow.ViewModel.init(title: "Fish Oil", subtitle: "1 Capsule", recurringTimestamp: "7:00AM, Every Day", overdue: false)
            ]))
        }.previewLayout(.sizeThatFits)
    }
}
