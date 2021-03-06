//
//  SearchListView.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-18.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI
import Combine

struct SearchListView: View {
    
    struct ViewModel {
        // Represents the type of view to show within the search results container
        enum ResultViewType {
            case searchResults
            case loading
            case info
        }
        var resultViewType: ResultViewType {
            if !results.isEmpty {
                return .searchResults
            } else if isSearching {
                return .loading
            } else {
                return .info
            }
        }
        var showAddNew: Bool {
            !queryIsEmpty &&
                results.firstIndex(where: { searchable in searchable.name.lowercased() == query.lowercased()}) == nil
        }
        
        let searchDescriptor: String // Medication, Nutrition, etc.
        var navigationBarTitle: String {
            "Search \(searchDescriptor)"
        }
        
        // Search
        @Binding var query: String
        var addNewItemName: String {
            query.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        var queryIsEmpty: Bool {
            query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        let isSearching: Bool
        let results: [LogSearchable]
        
        // Create new log item
        let isCreatingNewLogItem: Bool
        let createNewLogItemSuccess: Bool
        let createNewLogItemError: Bool
        var viewDisabled: Bool {
            isCreatingNewLogItem || createNewLogItemError || createNewLogItemSuccess
        }
        
        // Callbacks
        let onCancel: VoidCallback? // Cancel in nav bar pressed
        let onItemSelect: IntCallback? // Search result item pressed
        let onViewDismiss: VoidCallback? // View disappears
        let onAddNewSelect: StringCallback? // Add new item pressed
        let onAddNewSuccessShown: VoidCallback? // Finished adding new item
        let onAddNewErrorShown: VoidCallback? // Finished adding new item
        
        init(
                searchDescriptor: String,
                query: Binding<String>,
                isSearching: Bool,
                results: [LogSearchable],
                isCreatingNewLogItem: Bool,
                createNewLogItemSuccess: Bool,
                createNewLogItemError: Bool,
                onCancel: VoidCallback? = nil,
                onItemSelect: IntCallback? = nil,
                onViewDismiss: VoidCallback? = nil,
                onAddNewSelect: StringCallback? = nil,
                onAddNewSuccessShown: VoidCallback? = nil,
                onAddNewErrorShown: VoidCallback? = nil
        ) {
            self.searchDescriptor = searchDescriptor.capitalizeFirstLetter()
            self.isSearching = isSearching
            self._query = query
            self.results = results
            self.isCreatingNewLogItem = isCreatingNewLogItem
            self.createNewLogItemSuccess = createNewLogItemSuccess
            self.createNewLogItemError = createNewLogItemError
            self.onCancel = onCancel
            self.onItemSelect = onItemSelect
            self.onViewDismiss = onViewDismiss
            self.onAddNewSelect = onAddNewSelect
            self.onAddNewSuccessShown = onAddNewSuccessShown
            self.onAddNewErrorShown = onAddNewErrorShown
        }
    }
    
    private let viewModel: ViewModel
    @State private var showAddNewConfirmation: Bool = false
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(searchText: viewModel.$query)
            ScrollView {
                if viewModel.showAddNew {
                    AddNewListItemView(viewModel: getAddNewListItemViewModel())
                        .modifier(RoundedBorderSectionModifier())
                        .padding(.horizontal, CGFloat.Theme.Layout.Normal)
                        .padding(.top, CGFloat.Theme.Layout.Normal)
                }
                VStack {
                    HStack {
                        Text("Search Results")
                            .font(Font.Theme.Heading)
                            .foregroundColor(Color.Theme.Text)
                            .padding(.bottom, CGFloat.Theme.Layout.Small)
                        Spacer()
                    }
                    getResultView()
                        .modifier(RoundedBorderSectionModifier())
                }
                .padding(.all, CGFloat.Theme.Layout.Normal)
            }
        }
        // Disable/Enable interaction
        .disabled(self.viewModel.viewDisabled)
        // Loading/Success/Failure States
        .withLoadingPopup(show: .constant(self.viewModel.isCreatingNewLogItem), text: "Saving New Item")
        .withStandardPopup(show: .constant(self.viewModel.createNewLogItemSuccess), type: .success, text: "Saved Successfully") {
            self.viewModel.onAddNewSuccessShown?()
        }
        .withStandardPopup(show: .constant(self.viewModel.createNewLogItemError), type: .failure, text: "Something Went Wrong") {
            self.viewModel.onAddNewErrorShown?()
        }
        .onDisappear {
            self.viewModel.onViewDismiss?()
        }
        // Alert
        .alert(isPresented: self.$showAddNewConfirmation) {
            Alert(
                title: Text("Add Custom Item"),
                message: Text("Are you sure you want to add \(self.viewModel.addNewItemName) and select it from the list?"),
                primaryButton: .default(
                    Text("Confirm")
                        .foregroundColor(Color.Theme.Primary)
                ) {
                    self.viewModel.onAddNewSelect?(self.viewModel.addNewItemName)
                },
                secondaryButton: .cancel(
                    Text("Cancel")
                        .foregroundColor(Color.Theme.Primary)
                )
            )
        }
        // Navigation Bar
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.viewModel.onCancel?()
        }, label: {
            Text("Cancel")
                .font(Font.Theme.NormalText)
                .foregroundColor(Color.Theme.Primary)
        }))
        .navigationBarTitle(Text(viewModel.navigationBarTitle), displayMode: .inline)
        .background(Color.Theme.BackgroundPrimary)
    }
    
    private func getResultView() -> AnyView {
        switch viewModel.resultViewType {
        case .searchResults:
            return SearchResultsView(viewModel: getSearchResultsViewModel()).eraseToAnyView()
        case .loading:
            return FullWidthLoadingSpinner(size: .small)
                .padding(CGFloat.Theme.Layout.Normal)
                .eraseToAnyView()
        case .info:
            return SearchInfoView(viewModel: getSearchInfoViewModel())
                .eraseToAnyView()
        }
    }
    
    private func getAddNewListItemViewModel() -> AddNewListItemView.ViewModel {
        return AddNewListItemView.ViewModel(
            text: viewModel.addNewItemName,
            onTap: {
                self.$showAddNewConfirmation.wrappedValue.toggle()
        }
        )
    }
    
    private func getSearchResultsViewModel() -> SearchResultsView.ViewModel {
        return SearchResultsView.ViewModel(
            items: viewModel.results.enumerated().map { (index, item) in
                ListItemRow.ViewModel(
                    name: item.name,
                    onTap: { self.viewModel.onItemSelect?(index) }
                )
            }
        )
    }
    
    private func getSearchInfoViewModel() -> SearchInfoView.ViewModel {
        let infoText: String
        if viewModel.queryIsEmpty {
            infoText = "Search for \(viewModel.searchDescriptor.lowercased()) and select one from the list"
        } else {
            infoText = "No results found"
        }
        return SearchInfoView.ViewModel(text: infoText)
    }
    
}

struct SearchListView_Previews: PreviewProvider {
    
    static let results: [LogSearchable] = [
        Medication(id: "1", name: "One", createdBy: ""),
        Medication(id: "2", name: "Two", createdBy: "")
    ]
    static let emptyResults: [LogSearchable] = []
    
    static var withResultsViewModel: SearchListView.ViewModel {
        SearchListView.ViewModel(
            searchDescriptor: "Medications",
            query: .constant("Dela"),
            isSearching: false,
            results: results,
            isCreatingNewLogItem: false,
            createNewLogItemSuccess: false,
            createNewLogItemError: false
        )
    }
    
    static var loadingViewModel: SearchListView.ViewModel {
        SearchListView.ViewModel(
            searchDescriptor: "Medications",
            query: .constant("Dela"),
            isSearching: true,
            results: emptyResults,
            isCreatingNewLogItem: false,
            createNewLogItemSuccess: false,
            createNewLogItemError: false
        )
    }
    
    static var noResultsViewModel: SearchListView.ViewModel {
        SearchListView.ViewModel(
            searchDescriptor: "Medications",
            query: .constant("Dela"),
            isSearching: false,
            results: emptyResults,
            isCreatingNewLogItem: false,
            createNewLogItemSuccess: false,
            createNewLogItemError: false
        )
    }
    
    static var initialViewModel: SearchListView.ViewModel {
        SearchListView.ViewModel(
            searchDescriptor: "Medications",
            query: .constant(""),
            isSearching: false,
            results: emptyResults,
            isCreatingNewLogItem: false,
            createNewLogItemSuccess: false,
            createNewLogItemError: false
        )
    }
    
    static var previews: some View {
        Group {
            SearchListView(viewModel: withResultsViewModel)
            SearchListView(viewModel: loadingViewModel)
            SearchListView(viewModel: noResultsViewModel)
            SearchListView(viewModel: initialViewModel)
        }
    }
}
