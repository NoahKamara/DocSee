//
//  SidebarView.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI


struct SidebarView: View {
    @Environment(DocumentationContext.self)
    private var context

    @Environment(\.documentationWorkspace)
    var workspace
    
    let index: NavigatorIndex
    
    @State
    var language: SourceLanguage = .swift
    
    @Binding
    var selection: TopicReference?
    
    
    var body: some View {
        List(selection: $selection) {
            NavigatorTreeView(tree: index.tree)
            
            if index.tree.root.children.isEmpty {
                Text("No Content yet")
            }
        }
        .toolbar {
            ToolbarItem {
                Menu {
                    Button(action: {}) {
                        Label("Add documentation", systemImage: "book.pages")
                    }

                    Button(action: {
                        index.addGroupMarker("New Group")
                    }) {
                        Label("Add group mark", systemImage: "textformat")
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                } primaryAction: {
                    print("Add documentation")
                }
            }
        }
        .task {
            do {
                let provider = try AppBundleDataProvider(bundle: .main)
                let bundles = try provider.bundles()
                try await workspace.registerProvider(provider)
                for bundle in bundles {
                    index.dataProvider(workspace, didAddBundle: bundle)
                }
            } catch {
                print("Error registering Bundle Provider")
            }
        }
//        .safeAreaInset(
//            edge: .top,
//            content: {
//                HStack {
//                    Button("Insert New") {
//                        do {
//                            let provider = try LocalFileSystemDataProvider(rootURL: URL(filePath: "/Users/noahkamara/Developer/DocSee/DocSee/Resources/SlothCreator.doccarchive"))
//                            let bundle = try provider.bundles().first!
//
//                            Task {
//                                try await workspace.registerProvider(provider)
//                                index.dataProvider(workspace, didAddBundle: bundle)
//                            }
//                        } catch {
//                            print("ERROR", error)
//                        }
//                    }
//                    
//                    Button("Insert Known") {
//                        do {
//                            index.addBundleReference(
//                                bundleIdentifier: "TestDocumentation",
//                                displayName: "TestDocumentation"
//                            )
//                        let provider = try LocalFileSystemDataProvider(rootURL: URL(filePath: "/Users/noahkamara/Developer/DocSee/DocSee/Resources/TestDocumentation.doccarchive"))
//                        
//                        let bundle = try provider.bundles().first!
//                        
//                        Task {
//                            try await workspace.registerProvider(provider)
//                            index.dataProvider(workspace, didAddBundle: bundle)
//                        }
//                    } catch {
//                        print("ERROR", error)
//                    }
//                }
//            }
//        })
//        .toolbar {
//            Button("Add Bundle", systemImage: "plus") {
//                self.showsBundleBrowser.toggle()
//            }
//            Button("Log") {
//                print(self.tree.root.dumpTree())
//            }
//        }
//        .task {
//            do {
//                let provider = try LocalFileSystemDataProvider(
//                    rootURL: URL(
//                        filePath: "/Users/noahkamara/Developer/DocSee/DocSee/Resources/SlothCreator.doccarchive"
//                    )!
//                )
//                
//                let bundle = try provider.bundles().first!
//                print("LOADING")
//                
//                try await index.addProvider(bundle: bundle, for: provider)
//            } catch {
//                print("ERROR", error)
//            }
//        }
    }
}

#Preview(traits: .workspace) {
    @Previewable @State
    var selection = TopicReference?.none
    
    WorkspacePreview {
        SidebarView(
            index: NavigatorIndex(context: DocumentationContext(dataProvider: $0)),
            selection: $selection
        )
            .listStyle(.sidebar)
    }
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
            
            let descriptors = bundles.map({ bundle in
                DocumentationBundleDescriptor(
                    metadata: bundle.metadata,
                    provider: try! LocalFileSystemDataProvider(
                        rootURL: bundle.baseURL,
                        allowArbitraryCatalogDirectories: true
                    )
                )
            })
            
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
