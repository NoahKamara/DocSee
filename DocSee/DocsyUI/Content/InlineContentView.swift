import SwiftUI
import DocsySchema


struct InlineContentView: View {
    let content: [InlineContent]

    @Environment(DocumentReferenceResolver.self)
    private var references: DocumentReferenceResolver?

    var attributedString: AttributedString {
        content.attributed(with: references)
    }

    init(content: [InlineContent]) {
        self.content = content
    }

    init(_ content: [InlineContent]) {
        self.content = content
    }

    var body: some View {
        Text(attributedString)
    }
}


#Preview("Inline Content") {
    VStack(alignment: .leading) {
        PreviewDocument.primaryBlockContent(at: "/documentation/testdocumentation/styles") { blocks in
            let inlineContent: [InlineContent] = blocks.flatMap({ block in
                if case .paragraph(let paragraph) = block {
                    return paragraph.inlineContent + [.text(" ")]
                } else {
                    return [InlineContent]()
                }
            })

            InlineContentView(inlineContent)
                .frame(maxHeight: .infinity)
        }

        PreviewDocument.primaryBlockContent(at: "/documentation/testdocumentation/references") { blocks in
            let inlineContent: [InlineContent] = blocks.flatMap({ block in
                if case .paragraph(let paragraph) = block {
                    return paragraph.inlineContent + [.text(" ")]
                } else {
                    return [InlineContent]()
                }
            })

            InlineContentView(inlineContent)
                .frame(maxHeight: .infinity)
        }
    }
}


// MARK: Rendering
extension [InlineContent] {
    func attributed(with references: DocumentReferenceResolver? = nil) -> AttributedString {
        reduce(into: AttributedString()) { result, element in
            result += element.attributed(with: references)
        }
    }
}

extension InlineContent {
    func attributed(with references: DocumentReferenceResolver? = nil) -> AttributedString {
        var string: AttributedString

        switch self {
        case .codeVoice(let code):
            string = AttributedString(code)
            string.font = .body.monospaced()
            string.foregroundColor = .secondary

        case .emphasis(let inlineContent):
            string = inlineContent.attributed()
            string.font = (string.font ?? .body).italic()

        case .strong(let inlineContent):
            string = inlineContent.attributed()
            string.font = (string.font ?? .body).bold()

        case .strikethrough(let inlineContent):
            string = inlineContent.attributed()
            string.strikethroughStyle = .single
            string.strikethroughColor = .white

            //        case .image(let identifier, let metadata):

        case .reference(let identifier, let isActive, let overridingTitle, let overridingTitleInlineContent):
            string = AttributedString(identifier.identifier)
            let ref = references?[identifier]

            switch ref {
            case .image(let imageReference): break

            case .video(let videoReference): break

            case .file(let fileReference): break

            case .fileType(let fileTypeReference): break

            case .topic(let topicReference):
                string = AttributedString(topicReference.title)
                string.link = URL(string: topicReference.identifier.identifier)

            case .download(let downloadReference):
                string.link = downloadReference.url

            case .link(let linkReference):
                string = AttributedString(linkReference.title)
                string.link = URL(string: linkReference.url)

            default:
                string = .init("UNKNOWN \(identifier.identifier)")
            }



        case .text(let text):
            string = AttributedString(text)
            //
            //        case .newTerm(let inlineContent):
            //
            //        case .inlineHead(let inlineContent):
            //
            //        case .subscript(let inlineContent):
            //
            //        case .superscript(let inlineContent):
            //

        default:
            print("NOT IMPLEMENTED")
            string = AttributedString(self.plainText)
            string.foregroundColor = .red
        }

        return string
    }
}
