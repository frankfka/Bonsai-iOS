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
        RoundedBorderTitledSection(sectionTitle: "Symptom") {
            VStack {
                LogDetailItemView(viewModel: LogDetailItemView.ViewModel(title: "Symptom", value: self.viewModel.name))
                LogDetailItemView(viewModel: LogDetailItemView.ViewModel(title: "Severity", value: self.viewModel.severity))
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
