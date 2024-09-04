import DocsySchema
import SwiftUI

public struct DocumentView: View {
    let document: Document
    var references: DocumentReferenceResolver

    public init(_ document: Document) {
        self.document = document
        self.references = DocumentReferenceResolver(references: document.references)
    }

    public var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 5) {
                ContentHeaderView(
                    roleHeading: document.metadata.roleHeading,
                    title: document.metadata.title ?? document.identifier.url.lastPathComponent,
                    abstract: document.abstract
                )

                ContentSectionsView(document.primaryContentSections)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxWidth: 800)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .contentMargins(10, for: .scrollContent)
        .environment(references)
        .textSelection(.enabled)
    }
}

#Preview {
    PreviewDocument("/documentation/testdocumentation/markdown") { document in
        DocumentView(document)
    }
    .frame(maxWidth: 500, maxHeight: 900)
}
