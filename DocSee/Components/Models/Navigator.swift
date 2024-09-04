
import Docsy
import Observation

@Observable
public class Navigator {
    var history = History()
    var selection: TopicReference? {
        get {
            access(keyPath: \.history)
            return history.current
        }
        set {
            withMutation(keyPath: \.history) {
                if let newValue {
                    history.push(newValue)
                } else {
                    history.clear()
                }
            }
        }
    }

    public func goto(_ reference: TopicReference) {
        withMutation(keyPath: \.history) {
            history.push(reference)
        }
    }

    public var canGoBack: Bool {
        access(keyPath: \.history)
        return history.canGoBack
    }

    public var canGoForward: Bool {
        access(keyPath: \.history)
        return history.canGoForward
    }

    public func goBack() {
        withMutation(keyPath: \.history) {
            history.goBack()
        }
    }

    public func goBack(_ offset: Int) {
        for _ in 0..<offset {
            history.goBack()
        }
    }

    public func goForward() {
        withMutation(keyPath: \.history) {
            history.goForward()
        }
    }

    public func goForward(_ offset: Int) {
        for _ in 0..<offset {
            history.goForward()
        }
    }
}

extension Navigator {
    struct History {
        private(set) var future: [TopicReference] = []
        var current: TopicReference? { history.last }

        private(set) var history: [TopicReference] = []

        public var canGoBack: Bool { current != nil && history.count > 1 }
        public var canGoForward: Bool { current != nil && !future.isEmpty }

        mutating func push(_ reference: TopicReference) {
            clearFuture()
            history.append(reference)
        }

        public var pastItems: [TopicReference] { history.dropLast() }
        public var futureItems: [TopicReference] { future.reversed() }

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
