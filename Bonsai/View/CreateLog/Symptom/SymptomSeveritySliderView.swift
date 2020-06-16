//
//  SymptomSeveritySliderView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2020-01-04.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct SymptomSeveritySliderView: View {
    
    struct ViewModel {
        let severityString: String
        let sliderRange: ClosedRange<Double>
        let sliderValue: Double
        let sliderStep: Double
        let sliderValueChangeCallback: DoubleCallback?
        
        init(severityString: String, sliderRange: ClosedRange<Double>, sliderValue: Double, sliderStep: Double,
             sliderValueChangeCallback: DoubleCallback? = nil) {
            self.severityString = severityString
            self.sliderRange = sliderRange
            self.sliderValue = sliderValue
            self.sliderStep = sliderStep
            self.sliderValueChangeCallback = sliderValueChangeCallback
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: CGFloat.Theme.Layout.Small) {
                Text("Severity:")
                    .font(Font.Theme.NormalBoldText)
                    .foregroundColor(Color.Theme.Text)
                Text(viewModel.severityString)
                    .font(Font.Theme.NormalText)
                    .foregroundColor(Color.Theme.SecondaryText)
            }
            Slider(
                value: Binding<Double>(get: {
                    self.viewModel.sliderValue
                }, set: { newVal in
                    // Compare to value stored in view model - this prevents actions from firing if the new value is the same
                    if newVal != self.viewModel.sliderValue {
                        self.viewModel.sliderValueChangeCallback?(newVal)
                    }
                }),
                in: viewModel.sliderRange,
                step: viewModel.sliderStep
            )
                .accentColor(Color.Theme.Primary)
                .padding(.horizontal, CGFloat.Theme.Layout.Small)
        }
        .padding(CGFloat.Theme.Layout.Normal)
        .background(Color.Theme.BackgroundSecondary)
    }
}

struct SymptomSeveritySliderView_Previews: PreviewProvider {
    
    static let vm: SymptomSeveritySliderView.ViewModel = SymptomSeveritySliderView.ViewModel(
        severityString: "None",
        sliderRange: SymptomLog.Severity.least.rawValue...SymptomLog.Severity.most.rawValue,
        sliderValue: SymptomLog.Severity.normal.rawValue,
        sliderStep: SymptomLog.Severity.increment
    )
    
    static var previews: some View {
        SymptomSeveritySliderView(viewModel: vm)
    }
}
