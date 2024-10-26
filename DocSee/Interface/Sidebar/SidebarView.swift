//
//  SidebarView.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI

struct SidebarView: View {
    let tree: NavigatorTree

    @State
    var language: SourceLanguage = .swift

    @Bindable
    var navigator: Navigator
        
    var body: some View {
        List(selection: $navigator.selection) {
            BookmarksView()
            
            NavigatorTreeView(tree: tree)

            if tree.root.children.isEmpty {
                Text("No Content yet")
            }
        }
        .environment(navigator)
        .listStyle(.sidebar)
        .toolbar {
#if os(iOS) // editing is always enabled on macos 
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
#endif
            ToolbarItem {
                Menu {
                    Button(action: {}) {
                        Label("Add documentation", systemImage: "book.pages")
                    }

                    Button(action: {
                        tree.addGroupMarker("New Group")
                    }) {
                        Label("Add group mark", systemImage: "textformat")
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State
    var selection = TopicReference?.none

    SidebarView(
        tree: .preview(),
        navigator: Navigator()
    )
    .listStyle(.sidebar)
    .frame(maxHeight: .infinity)
}

struct DocumentationBundleDescriptor: Identifiable {
    var id: String { bundleIdentifier }
    let metadata: DocumentationBundle.Metadata

    var displayName: String { metadata.displayName }
    var bundleIdentifier: String { metadata.identifier }

    var provider: DataProvider
}

struct BundleBrowserView: View {
    let onSubmit: (DocumentationBundleDescriptor) -> Void

    @Environment(\.dismiss)
    var dismiss

    @State
    private(set) var results: [DocumentationBundleDescriptor] = []

    @State
    private(set) var isLoading: Bool = false

    var body: some View {
        Group {
            if !results.isEmpty {
                List {
                    ForEach(results) { bundle in
                        Button(action: {
                            onSubmit(bundle)
                            dismiss()
                        }) {
                            Text(bundle.displayName)
                        }
                    }
                }
            } else {
                ContentUnavailableView {
                    Text("No Bundles")
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .task {
            do {
                try await load()
            } catch {
                print("failed to load bundles in browser: \(error)")
            }
        }
    }

    func load() async throws {
        let results = try await Task.detached {
            let provider = try AppBundleDataProvider(bundle: .main)
            let bundles = try provider.bundles()

            let descriptors = bundles.map { bundle in
                DocumentationBundleDescriptor(
                    metadata: bundle.metadata,
                    provider: try! LocalFileSystemDataProvider(
                        rootURL: bundle.baseURL,
                        allowArbitraryCatalogDirectories: true
                    )
                )
            }

            return descriptors
        }.value

        Task { @MainActor in
            self.results = results
//                self.isLoading = false
        }
    }
}

#Preview {
    BundleBrowserView(onSubmit: {
        print($0.bundleIdentifier)
    })
}
