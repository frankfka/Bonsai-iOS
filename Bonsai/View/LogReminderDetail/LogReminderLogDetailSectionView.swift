//
// Created by Frank Jia on 2020-06-21.
// Copyright (c) 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogReminderLogDetailSectionView: View {

    struct ViewModel {
        let logTitle: String
        let logCategory: String

        init(loggable: Loggable) {
            self.logTitle = loggable.title
            self.logCategory = loggable.category.displayValue()
        }
    }
    private let viewModel: ViewModel

    init(vm: ViewModel) {
        self.viewModel = vm
    }

    // MARK: Main view
    var body: some View {
        TitledSection(sectionTitle: "Log Details") {
            VStack(spacing: 0) {
                TappableRowView(
                    viewModel: TappableRowView.ViewModel(
                        primaryText: .constant("Log"),
                        secondaryText: .constant(self.viewModel.logTitle),
                        hasDisclosureIndicator: false
                    )
                )
                Divider()
                TappableRowView(
                    viewModel: TappableRowView.ViewModel(
                        primaryText: .constant("Category"),
                        secondaryText: .constant(self.viewModel.logCategory),
                        hasDisclosureIndicator: false
                    )
                )
            }
        }
    }
}
