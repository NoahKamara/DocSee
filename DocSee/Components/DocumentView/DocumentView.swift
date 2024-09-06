import SwiftUI
import UniformTypeIdentifiers
import Docsy
import BundleAppSourceProvider
import DocCViewer

struct DocumentView: View {
    let navigator: Navigator

    @State
    var viewer: DocumentationViewer

    init(context: DocumentationContext, navigator: Navigator) {
        let bundleProvider = DocsyResourceProvider(context: context)
        let provider = BundleAppSourceProvider(bundleProvider: bundleProvider)
//        self.context = context
        self.viewer = DocumentationViewer(provider: provider)
        self.navigator = navigator
    }

    var body: some View {
        DocumentationView(viewer: viewer)
            .onChange(of: navigator.selection, initial: true) { _, newValue in
                guard let newValue else { return }
                viewer.load(.init(bundleIdentifier: newValue.bundleIdentifier, path: newValue.path))
            }
    }
}
