//
//  SearchBar.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-18.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

// https://medium.com/better-programming/implement-searchbar-in-swiftui-556a204e1970
struct SearchBar : UIViewRepresentable {
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var searchText : String
        
        init(textBinding: Binding<String>) {
            _searchText = textBinding
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.searchText = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
    
    @Binding var searchText: String
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(textBinding: $searchText)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.returnKeyType = .search
        searchBar.placeholder = "Search"
        searchBar.tintColor = Color.Theme.primaryUIColor
        searchBar.searchTextField.font = Font.Theme.normalTextUIFont
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = searchText
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchBar(searchText: .constant(""))
        }.previewLayout(.sizeThatFits)
    }
}
