

import Foundation
import SwiftUI
import Docsy

//struct TestView: View {
//    @Environment(DocCOnte.self)
//    var ws
//
//    var body: some View {
//        NavigationStack {
//            List {
//                Section("Bundles") {
//                    ForEach(ws.bundles.keys.sorted(), id:\.self) { identifier in
//                        Text(identifier)
//                    }
//                }
//            }
//        }
//    }
//}
//


struct PreviewWorkspace: PreviewModifier {
    static func makeSharedContext() async throws -> (DocumentationWorkspace, DocumentationContext) {
        let workspace = DocumentationWorkspace()
        let context = DocumentationContext(dataProvider: workspace)

        let provider = try LocalFileSystemDataProvider(bundle: .main)
        try await workspace.registerProvider(provider)

        return (workspace, context)
    }

    func body(content: Content, context: (DocumentationWorkspace, DocumentationContext)) -> some View {
        content
            .environment(\.documentationWorkspace, context.0)
            .environment(context.1)
    }
}


extension PreviewTrait where T == Preview.ViewTraits {
    public static var workspace: PreviewTrait<T> {
        Self.modifier(PreviewWorkspace())
    }
}
