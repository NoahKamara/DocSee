import DocsySchema
import SwiftUI

struct CodeListingView: View {
    let codeListing: BlockContent.CodeListing

    init(_ codeListing: BlockContent.CodeListing) {
        self.codeListing = codeListing
    }

    var code: String { codeListing.code.joined(separator: "\n") }

    var body: some View {
        CalloutView(.primary) {
            ScrollView(.horizontal) {
                Text(code)
                    .lineLimit(codeListing.code.count, reservesSpace: true)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            .monospaced()
        }
    }
}

#Preview {
    PreviewDocument("//documentation/testdocumentation/codelisting")
}
