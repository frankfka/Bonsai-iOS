//
//  LogDetailSymptomView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-01-14.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct LogDetailSymptomView: View {

    struct ViewModel {
        let name: String
        let severity: String
    }
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TitledSection(sectionTitle: "Symptom") {
            VStack(spacing: 0) {
                TappableRowView(
                        viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Name"),
                                secondaryText: .constant(self.viewModel.name),
                                hasDisclosureIndicator: false
                        )
                )
                Divider()
                TappableRowView(
                        viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Severity"),
                                secondaryText: .constant(self.viewModel.severity),
                                hasDisclosureIndicator: false
                        )
                )
            }
        }
    }
}

struct LogDetailSymptomView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailSymptomView(
                viewModel: LogDetailSymptomView.ViewModel(name: "Fatigue", severity: "Extreme")
        )
            .previewLayout(.sizeThatFits)
    }
}
