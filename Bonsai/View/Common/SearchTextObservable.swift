//
// Created by Frank Jia on 2019-12-21.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import SwiftUI
import Combine

// From https://github.com/Dimillian/MovieSwiftUI/blob/master/MovieSwift/MovieSwift/binding/SearchTextObservable.swift
class SearchTextObservable: ObservableObject {
    @Published var searchText = "" {
        willSet {
            DispatchQueue.main.async {
                self.searchSubject.send(newValue)
            }
        }
        didSet {
            DispatchQueue.main.async {
                self.onUpdateText?(self.searchText)
            }
        }
    }
    let searchSubject = PassthroughSubject<String, Never>()
    private var searchDebounceCancellable: Cancellable? {
        didSet {
            oldValue?.cancel()
        }
    }

    private let onUpdateText: StringCallback?

    deinit {
        searchDebounceCancellable?.cancel()
    }

    init(onUpdateText: StringCallback? = nil, onUpdateTextDebounced: StringCallback? = nil) {
        searchDebounceCancellable = searchSubject.eraseToAnyPublisher()
                .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                // Remove duplicates that are just whitespace
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .removeDuplicates()
                .sink(receiveValue: { (searchText) in
                    onUpdateTextDebounced?(searchText)
                })
        self.onUpdateText = onUpdateText
    }
}
