//
//  LogDetailView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-01-14.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

// TODO: On load, dispatch action to create state, use this to retrieve required metadata
struct LogDetailView: View {

    struct ViewModel {
        let loggable: Loggable
        let logDate: String
        let logCategory: String
        let logCategoryColor: Color

        init(loggable: Loggable) {
            self.loggable = loggable
            self.logDate = loggable.dateCreated.description
            self.logCategory = loggable.category.displayValue()
            self.logCategoryColor = loggable.category.displayColor()
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // TODO: Add date, category, etc
    // TODO: Deletion, relog, etc
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(self.viewModel.logDate)
                Text(self.viewModel.logCategory)
                Text(self.viewModel.logDate)
                Text(self.viewModel.logCategory)
                Text(self.viewModel.logDate)
                Text(self.viewModel.logCategory)
                Text(self.viewModel.logDate)
                Text(self.viewModel.logCategory)
                LogDetailNotesView(viewModel: getNotesViewModel())
            }
            .padding(.all, CGFloat.Theme.Layout.normal)
        }
        .background(Color.Theme.backgroundPrimary)
        .navigationBarTitle("Log Details")
    }
    
    func getSymptomDetailViewModel() -> LogDetailSymptomView.ViewModel? {
        let loggable = viewModel.loggable
        guard loggable.category == .symptom, let symptomLog = loggable as? SymptomLog else {
            return nil
        }
        return LogDetailSymptomView.ViewModel(name: "Test Name", severity: symptomLog.severity.displayValue())
    }
    
    func getNotesViewModel() -> LogDetailNotesView.ViewModel {
        return LogDetailNotesView.ViewModel(notes: self.viewModel.loggable.notes)
    }
    
    
}

struct LogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailView(
            viewModel: LogDetailView.ViewModel(
                loggable: NoteLog(id: "", title: "", dateCreated: Date(), notes: "Example notes")
            )
        )
    }
}
