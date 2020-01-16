//
// Created by Frank Jia on 2020-01-15.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI

extension DateFormatter {
    // Full Date * Time
    private static var logDetailDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a, MMM d, yyyy"
        return dateFormatter
    }
    static func stringForLogDetailDate(from date: Date) -> String {
        return logDetailDateFormatter.string(from: date)
    }
}

struct LogDetailBasicsView: View {

    struct ViewModel {
        let category: String
        let createdDate: String

        init(loggable: Loggable) {
            self.category = loggable.category.displayValue()
            self.createdDate = DateFormatter.stringForLogDetailDate(from: loggable.dateCreated)
        }
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TitledSection(sectionTitle: "General") {
            VStack(spacing: 0) {
                TappableRowView(
                        viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Date Created"),
                                secondaryText: .constant(self.viewModel.createdDate),
                                hasDisclosureIndicator: false
                        )
                )
                Divider()
                TappableRowView(
                        viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Category"),
                                secondaryText: .constant(self.viewModel.category),
                                hasDisclosureIndicator: false
                        )
                )
            }
        }
    }
}

