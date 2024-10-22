//
//  Navigator.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import Observation

@Observable
@MainActor
public class Navigator {
    var selection: TopicReference?
    var index: NavigatorIndex

    public func goto(_ reference: TopicReference) {
        withMutation(keyPath: \.selection) {
            self.selection = reference
        }
    }

    init(
        index: NavigatorIndex? = nil,
        initialTopic: TopicReference? = nil
    ) {
        self.index = index ?? NavigatorIndex()
        self.selection = initialTopic
    }
}

extension Navigator {
    struct History {
        private(set) var future: [TopicReference] = []
        var current: TopicReference? { history.last }

        private(set) var history: [TopicReference] = []

        init(current: TopicReference? = nil) {
            self.future = []
            self.history = current.map { [$0] } ?? []
        }

        var canGoBack: Bool { current != nil && history.count > 1 }
        var canGoForward: Bool { current != nil && !future.isEmpty }

        mutating func push(_ reference: TopicReference) {
            clearFuture()
            history.append(reference)
        }

        var pastItems: [TopicReference] { history.dropLast() }
        var futureItems: [TopicReference] { future.reversed() }

        mutating func goBack() {
            guard !history.isEmpty else { return }
            future.append(history.removeLast())
        }

        mutating func goForward() {
            guard !future.isEmpty else { return }
            history.append(future.removeLast())
        }

        private mutating func clearHistory() { history.removeAll() }
        private mutating func clearFuture() { future.removeAll() }

        mutating func clear() {
            clearFuture()
            clearHistory()
        }
    }
}
