//
//  Preview.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import Foundation
import SwiftUI

struct PreviewWorkspace: PreviewModifier {
    static func makeSharedContext() async throws -> (DocumentationWorkspace, DocSeeContext) {
        let workspace = DocumentationWorkspace()
        let context = DocSeeContext(workspace: workspace)

        do {
            let provider = try AppBundleDataProvider(bundle: .main)
            try await workspace.registerProvider(provider)

            let indexProvider = DocSeeIndexProvider(
                path: "docsee/testdocumentation"
            )

            try await workspace.registerProvider(indexProvider)
        } catch {
            print("ERROR in provider", error)
        }

        return (workspace, context)
    }

    func body(content: Content, context: (DocumentationWorkspace, DocSeeContext)) -> some View {
        content
            .environment(\.documentationWorkspace, context.0)
            .environment(context.1)
    }
}

public extension PreviewTrait where T == Preview.ViewTraits {
    static var workspace: PreviewTrait<T> {
        modifier(PreviewWorkspace())
    }
}

struct WorkspacePreview<Content: View>: View {
    @Environment(\.documentationWorkspace)
    var workspace

    @ViewBuilder
    var content: (DocumentationWorkspace) -> Content

    var body: some View {
        content(workspace)
    }
}

struct ProviderTestView: View {
    @State
    var bundles: [DocumentationBundle] = []

    @Environment(\.documentationWorkspace)
    var workspace

    var body: some View {
        List {
            ForEach(bundles) { bundle in
                VStack(alignment: .leading) {
                    Text(bundle.displayName)
                    Text(bundle.identifier)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
        }
        .task {
            print("LOAD")
            let provider = DocSeeIndexProvider(path: "docsee/testdocumentation")
            do {
                let bundles = try await provider.bundles()
                Task { @MainActor in
                    self.bundles = bundles
                }
                try await workspace.registerProvider(provider)
            } catch {
                print("Error", error)
            }
        }
    }
}

#Preview(traits: .workspace) {
    ProviderTestView()
}
