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
    static func makeSharedContext() async throws -> (DocumentationWorkspace, DocumentationContext) {
        let workspace = DocumentationWorkspace()
        let context = DocumentationContext(dataProvider: workspace)

        do {
            let provider = try AppBundleDataProvider(bundle: .main)
            try await workspace.registerProvider(provider)
        } catch {
            print("ERROR in provider", error)
        }

        return (workspace, context)
    }

    func body(content: Content, context: (DocumentationWorkspace, DocumentationContext)) -> some View {
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
