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
            !queryIsEmpty
        }

        let searchDescriptor: String // Medication, Nutrition, etc.
        var navigationBarTitle: String {
            "Search \(searchDescriptor)"
        }

        // Search
        @Binding var query: String
        var queryIsEmpty: Bool {
            query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        let isSearching: Bool
        let results: [LogSearchable]

        // Callbacks
        let onCancel: VoidCallback? // Cancel in nav bar pressed
        let onItemSelect: IntCallback? // Search result item pressed

        init(
            searchDescriptor: String,
            query: Binding<String>,
            isSearching: Bool,
            results: [LogSearchable],
            onCancel: VoidCallback? = nil,
            onItemSelect: IntCallback? = nil
        ) {
            self.searchDescriptor = searchDescriptor.capitalizeFirstLetter()
            self.isSearching = isSearching
            self._query = query
            self.results = results
            self.onCancel = onCancel
            self.onItemSelect = onItemSelect
        }
    }
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: CGFloat.Theme.Layout.normal) {
            SearchBar(searchText: viewModel.$query)
            if viewModel.showAddNew {
                AddNewListItemView(viewModel: getAddNewListItemViewModel())
                    .modifier(RoundedBorderSection())
                    .padding(.horizontal, CGFloat.Theme.Layout.normal)
                    .padding(.vertical, CGFloat.Theme.Layout.small)
            }
            VStack {
                HStack {
                    Text("Search Results")
                            .font(Font.Theme.heading)
                            .foregroundColor(Color.Theme.textDark)
                            .padding(.bottom, CGFloat.Theme.Layout.small)
                    Spacer()
                }
                getResultView()
                    .modifier(RoundedBorderSection())
            }
            .padding(.horizontal, CGFloat.Theme.Layout.normal)
            Spacer()
        }
        .navigationBarItems(leading: Button(action: {
            self.viewModel.onCancel?()
        }, label: {
            Text("Cancel")
                .font(Font.Theme.normalText)
                .foregroundColor(Color.Theme.primary)
        }))
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle(viewModel.navigationBarTitle)
            .edgesIgnoringSafeArea(.bottom)
            .background(Color.Theme.backgroundPrimary)
    }
    
    private func getResultView() -> AnyView {
        switch viewModel.resultViewType {
        case .searchResults:
            return AnyView(
                SearchResultsView(viewModel: getSearchResultsViewModel())
            )
        case .loading:
            return AnyView(
                FullWidthLoadingSpinner(size: .small)
                    .padding(CGFloat.Theme.Layout.normal)
            )
        case .info:
            return AnyView(
                SearchInfoView(viewModel: getSearchInfoViewModel())
            )
        }
    }
    
    private func getAddNewListItemViewModel() -> AddNewListItemView.ViewModel {
        return AddNewListItemView.ViewModel(text: viewModel.$query, onTap: nil)
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
            results: results
        )
    }
    
    static var loadingViewModel: SearchListView.ViewModel {
        SearchListView.ViewModel(
            searchDescriptor: "Medications",
            query: .constant("Dela"),
            isSearching: true,
            results: emptyResults
        )
    }
    
    static var noResultsViewModel: SearchListView.ViewModel {
        SearchListView.ViewModel(
            searchDescriptor: "Medications",
            query: .constant("Dela"),
            isSearching: false,
            results: emptyResults
        )
    }
    
    static var initialViewModel: SearchListView.ViewModel {
        SearchListView.ViewModel(
            searchDescriptor: "Medications",
            query: .constant(""),
            isSearching: false,
            results: emptyResults
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
