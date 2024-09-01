
import SwiftUI
import Docsy

struct NavigatorIndexView: View {
    @State
    var index: NavigatorIndex

    @State
    var hasLoaded: Bool = false

    init(identifier: BundleIdentifier, context: DocumentationContext) {
        self.index = NavigatorIndex(identifier: identifier, context: context)
    }

    var body: some View {
        if !index.root.languages.isEmpty {
            NavigatorTreeView(root: index.root, language: .swift)
        } else {
            Text(index.identifier)
                .task(id: "bootstrap") {
                    do {
                        try await index.bootstrap()
                    } catch let describedError as DescribedError {
                        print(describedError.errorDescription)
                    } catch {
                        print(error)
                    }
                    hasLoaded = true
                }
        }
    }
}



