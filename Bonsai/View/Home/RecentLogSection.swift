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
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if self.viewModel.showNoRecents {
                NoRecentLogsView()
            } else {
                ForEach(viewModel.recentLogs) { logVm in
                    Group {
                        NavigationLink(
                                destination: LogDetailView(viewModel: LogDetailView.ViewModel(loggable: logVm.loggable))
                        ) {
                            LogRow(viewModel: logVm)
                        }
                        if self.showDivider(after: logVm) {
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
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("No recent logs found")
                    .font(Font.Theme.heading)
                    .foregroundColor(Color.Theme.textDark)
            Text("Begin by adding a log using the \"+\" icon below")
                    .font(Font.Theme.normalText)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.Theme.text)
            Spacer()
        }
        .padding(CGFloat.Theme.Layout.normal)
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

struct RecentLogSection_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            RecentLogSection(
                    viewModel: RecentLogSection.ViewModel(
                            recentLogs: [
                                LogRow.ViewModel(loggable: PreviewLoggables.medication),
                                LogRow.ViewModel(loggable: PreviewLoggables.notes)
                            ]
                    )
            )
        }.previewLayout(.sizeThatFits)
    }
}
