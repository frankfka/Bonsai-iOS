//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import SwiftUI

// Wrapper around search list view for medications
struct SearchListViewContainer: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var searchTextObservable: SearchTextObservable

    // TODO: Very hard to not have this in the constructor, so keeping for now
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
                searchDescriptor: store.state.createLog.selectedCategory.displayValue(plural: true),
                query: Binding<String>(get: {
                    return self.searchTextObservable.searchText
                }, set: { newVal in
                    self.searchTextObservable.searchText = newVal
                }),
                isSearching: store.state.createLog.isSearching,
                results: store.state.createLog.searchResults,
                isCreatingNewLogItem: store.state.createLog.isCreatingLogItem,
                createNewLogItemSuccess: store.state.createLog.createLogItemSuccess,
                createNewLogItemError: store.state.createLog.createLogItemError != nil,
                onCancel: { self.presentationMode.wrappedValue.dismiss() },
                onItemSelect: { selectedIndex in
                    self.store.send(.createLog(action: .searchItemDidSelect(selectedIndex: selectedIndex)))
                    self.presentationMode.wrappedValue.dismiss()
                },
                onViewDismiss: {
                    self.store.send(.createLog(action: .onSearchViewDismiss))
                },
                onAddNewSelect: { addNewItemName in
                    self.store.send(.createLog(action: .onAddSearchItemPressed(name: addNewItemName)))
                },
                onAddNewSuccessShown: {
                    // Reducer currently selects this item, so just dismiss the view
                    self.presentationMode.wrappedValue.dismiss()
                    self.store.send(.createLog(action: .onAddSearchResultPopupShown))
                },
                onAddNewErrorShown: {
                    self.store.send(.createLog(action: .onAddSearchResultPopupShown))
                }
        )
    }
}
