//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import SwiftUI

// Wrapper around search list view for medications
struct MedicationSearchListView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var searchTextObservable: SearchTextObservable

    init(onUpdateQueryDebounced: @escaping StringCallback) {
        self._searchTextObservable = State(
                initialValue: SearchTextObservable(onUpdateTextDebounced: { q in
                    onUpdateQueryDebounced(q)
                })
        )
    }

    var body: some View {
        SearchListView(viewModel: getSearchListViewModel())
    }

    func getSearchListViewModel() -> SearchListView.ViewModel {
        return SearchListView.ViewModel(
                searchDescriptor: LogCategory.medication.displayValue(plural: true),
                query: Binding<String>(get: {
                    return self.searchTextObservable.searchText
                }, set: { newVal in
                    self.searchTextObservable.searchText = newVal
                }),
                isSearching: store.state.createLog.isSearching,
                results: store.state.createLog.searchResults,
                onCancel: { self.presentationMode.wrappedValue.dismiss() },
                onItemSelect: { selectedIndex in
                    self.store.send(.createLog(action: .searchItemDidSelect(selectedIndex: selectedIndex)))
                    self.presentationMode.wrappedValue.dismiss()
                },
                onAddNewSelect: { addNewItemName in
                    // TODO
                    print(addNewItemName)
                }
        )
    }
}
