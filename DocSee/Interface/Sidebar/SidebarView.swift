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

    @State
    var showsBundleBrowser: Bool = false
    
    @Environment(DocSeeContext.self)
    private var context
    
    var body: some View {
        List(selection: $navigator.selection) {
//            BookmarksView()

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
                    Button(action: {
                        self.showsBundleBrowser = true
                    }) {
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
        .sheet(isPresented: $showsBundleBrowser) {
            BundleBrowserView { bundle in
                try await context.addBundle(
                    displayName: bundle.metadata.displayName,
                    bundleIdentifier: bundle.metadata.identifier,
                    source: bundle.source
                )
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
