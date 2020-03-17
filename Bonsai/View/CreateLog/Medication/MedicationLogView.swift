//
//  MoodLogView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-16.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

struct MedicationLogView: View {
    @EnvironmentObject var store: AppStore

    struct ViewModel {
        @Binding var selectMedicationRowTitle: String
        @Binding var dosage: String

        init(selectMedicationRowTitle: Binding<String>, dosage: Binding<String>) {
            self._selectMedicationRowTitle = selectMedicationRowTitle
            self._dosage = dosage
        }
    }
    private var viewModel: ViewModel {
        getViewModel()
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(
                    destination: SearchListViewContainer(
                            onUpdateQueryDebounced: onUpdateQueryDebounced
                    )
            ) {
                TappableRowView(
                        viewModel: TappableRowView.ViewModel(
                                primaryText: viewModel.$selectMedicationRowTitle,
                                secondaryText: .constant(""),
                                hasDisclosureIndicator: true)
                )
            }
            Divider()
            CreateLogTextField(viewModel: getDosageViewModel())
        }
                .background(Color.Theme.backgroundSecondary)
    }

    func onUpdateQueryDebounced(query: String) {
        store.send(.createLog(action: .searchQueryDidChange(query: query)))
    }

    func getViewModel() -> MedicationLogView.ViewModel {
        let medicationLogState = store.state.createLog.medication
        let titleText = medicationLogState.selectedMedication?.name ?? "Select a \(LogCategory.medication.displayValue())"
        return ViewModel(
                selectMedicationRowTitle: .constant(titleText),
                dosage: Binding<String>(get: {
                    medicationLogState.dosage
                }, set: { newDosage in
                    self.store.send(.createLog(action: .medicationDosageDidChange(newDosage: newDosage)))
                })
        )
    }

    func getDosageViewModel() -> CreateLogTextField.ViewModel {
        return CreateLogTextField.ViewModel(label: "Dosage", input: viewModel.$dosage)
    }

}