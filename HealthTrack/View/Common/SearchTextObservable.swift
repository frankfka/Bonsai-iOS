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
    private var searchCancellable: Cancellable? {
        didSet {
            oldValue?.cancel()
        }
    }

    private let onUpdateText: StringCallback?
    private let onUpdateTextDebounced: StringCallback?

    deinit {
        searchCancellable?.cancel()
    }

    init(onUpdateText: StringCallback? = nil, onUpdateTextDebounced: StringCallback? = nil) {
        searchCancellable = searchSubject.eraseToAnyPublisher()
                .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .removeDuplicates()
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .sink(receiveValue: { (searchText) in
                    onUpdateTextDebounced?(searchText)
                })
        // TODO: just use this like in the cancellable above?
        self.onUpdateText = onUpdateText
        self.onUpdateTextDebounced = onUpdateTextDebounced
    }
}
