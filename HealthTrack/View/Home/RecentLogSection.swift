//
//  RecentLogSection.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct RecentLogSection: View {
    
    struct ViewModel {
        var showNoRecents: Bool {
            recentLogs.isEmpty
        }
        let recentLogs: [RecentLogRow.ViewModel]
    }
    
    let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if self.viewModel.showNoRecents {
                NoRecentLogsView()
            } else {
                ForEach(viewModel.recentLogs) { log in
                    RecentLogRow(viewModel: log)
                }
            }
        }
    }
}

struct NoRecentLogsView: View {
    // TODO: Formatting
    var body: some View {
        VStack(alignment: .center) {
            Text("No recent logs found")
            Text("Begin by adding a log using the \"+\" icon below")
        }
        .padding(CGFloat.Theme.Layout.normal)
    }
}

struct RecentLogSection_Previews: PreviewProvider {

    static let medicationLog: RecentLogRow.ViewModel = RecentLogRow.ViewModel(
            id: "",
            categoryName: "Medication",
            categoryColor: LogCategory.medication.displayColor(),
            logName: "Test Medication",
            timeString: "Tuesday, Feb 2, 2019"
    )

    static var previews: some View {
        Group {
            RecentLogSection(
                    viewModel: RecentLogSection.ViewModel(
                            recentLogs: [medicationLog]
                    )
            )
        }.previewLayout(.sizeThatFits)
    }
}
