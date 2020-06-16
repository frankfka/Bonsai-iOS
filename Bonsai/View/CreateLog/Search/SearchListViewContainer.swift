//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import SwiftUI

// TODO: Need to find a cleaner way of doing this
// Wrapper around search list view
struct SearchListViewContainer: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var searchTextObservable: SearchTextObservable // This needs to be a @State to make sure the query doesn't reset on VM change

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
                query: self.$searchTextObservable.searchText,
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
