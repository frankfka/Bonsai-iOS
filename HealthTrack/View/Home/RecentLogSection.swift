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
        let recentLogs: [LogRow.ViewModel]
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
                    Group {
                        LogRow(viewModel: log)
                        if self.showDivider(after: log) {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private func showDivider(after vm: LogRow.ViewModel) -> Bool {
        if let index = viewModel.recentLogs.firstIndex(where: { log in log.id == vm.id }),
           index < self.viewModel.recentLogs.count - 1 {
            return true
        }
        return false
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

    static let medicationLog: LogRow.ViewModel = LogRow.ViewModel(
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
