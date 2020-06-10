//
//  DatePickerView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2020-01-08.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

struct DatePickerView: View {
    
    struct ViewModel {
        @Binding var selectedDate: Date
        
        init(selectedDate: Binding<Date>) {
            self._selectedDate = selectedDate
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            DatePicker(selection: self.viewModel.$selectedDate, in: ...Date(), displayedComponents: .date) {
                // Hiding labels, so this is empty
                Text("")
            }
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            // Jump to Today Button
            Button(action: {
                self.onJumpToTodayTapped()
            }) {
                Text("Jump to Today")
                    .font(Font.Theme.NormalText)
                    .foregroundColor(Color.Theme.Primary)
            }
            .padding(.all, CGFloat.Theme.Layout.Small)
        }
        .padding(.all, CGFloat.Theme.Layout.Small)
        .frame(minWidth: 0, maxWidth: .infinity)
    }
    
    private func onJumpToTodayTapped() {
        self.viewModel.selectedDate = Date()
    }
    
}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerView(viewModel: DatePickerView.ViewModel(selectedDate: .constant(Date())))
            .previewLayout(.sizeThatFits)
    }
}
