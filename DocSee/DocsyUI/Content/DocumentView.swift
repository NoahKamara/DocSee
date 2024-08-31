import SwiftUI
import DocsySchema

public struct DocumentView: View {
    let document: Document
    var references: DocumentReferenceResolver

    public init(_ document: Document) {
        self.document = document
        self.references = DocumentReferenceResolver(references: document.references)
    }

    public var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading) {
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
        .environment(references)
    }
}

