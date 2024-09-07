//
//  DocumentView.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import BundleAppSourceProvider
import DocCViewer
import Docsy
import SwiftUI
import UniformTypeIdentifiers

struct DocumentView: View {
    let navigator: Navigator

    @State
    var viewer: DocumentationViewer

    init(context: DocumentationContext, navigator: Navigator) {
        let bundleProvider = DocsyResourceProvider(context: context)
        let provider = BundleAppSourceProvider(bundleProvider: bundleProvider)
        self.viewer = DocumentationViewer(provider: provider)
        self.navigator = navigator
    }

    var body: some View {
        DocumentationView(viewer: viewer)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    NavigationButtons(viewer: viewer)
                }
            }
            .onChange(of: navigator.selection, initial: true) { _, newValue in
                guard let newValue else { return }
                viewer.load(.init(bundleIdentifier: newValue.bundleIdentifier, path: newValue.path))
            }
    }
}

struct NavigationButtons: View {
    let viewer: DocumentationViewer

    var body: some View {
        ControlGroup {
            Button(action: { viewer.goBack() }) {
                Image(systemName: "chevron.backward")
            }
            .disabled(!viewer.canGoBack)

            Button(action: { viewer.goForward() }) {
                Image(systemName: "chevron.forward")
            }
            .disabled(!viewer.canGoForward)
        }
        .controlGroupStyle(.navigation)
    }
}
