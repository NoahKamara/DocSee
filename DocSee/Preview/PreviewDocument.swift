import SwiftUI
import DocsySchema


struct PreviewDocument<Content: View>: View {
    let content: (Document) -> Content
    let reference: TopicReference


    init(
        _ path: String = "/documentation/testdocumentation/styles",
        @ViewBuilder content: @escaping (Document) -> Content
    ) {
        self.reference = TopicReference(
            bundleIdentifier: "com.noahkamara.TestDocumentation",
            path: path,
            sourceLanguage: .swift
        )

        self.content = content
    }

    init<T>(
        _ path: String = "/documentation/testdocumentation/styles",
        keyPath: KeyPath<Document,T>,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.reference = TopicReference(
            bundleIdentifier: "com.noahkamara.TestDocumentation",
            path: path,
            sourceLanguage: .swift
        )

        self.content = { content($0[keyPath: keyPath]) }
    }

    func load() async throws {
        print("Loading Preview ")
        let rootURL = Bundle.main.resourceURL?.appending(components: "TestDocumentation.doccarchive", "data")

        guard let rootURL = rootURL?.absoluteURL else {
            print("No Resource URL in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: rootURL.appending(path: reference.path.appending(".json")))
            let document = try JSONDecoder().decode(Document.self, from: data)
            self.document = document
        } catch {
            print(error)
            throw error
        }
    }

    @State
    private var error: (any Error)? = nil

    @State
    private var hasWaited: Bool = false

    @State
    var document: Document? = nil

    var body: some View {
        Group {
            if let document {
                content(document)
                    .environment(DocumentReferenceResolver(references: document.references))
            } else if let error {
                ContentUnavailableView {
                    Label("Preview Error: \(error)", systemImage: "exclamationmark.octagon")
                } description: {
                    Text("Error: \(error)")
                }
            } else {
                ProgressView("Loading \(reference.url)")
            }
        }
        .task(id: "preview-doc-load") {
            Task {
                try await Task.sleep(for: .seconds(1))
                hasWaited = true
            }

            do {
                try await load()
            } catch {
                self.error = error
            }
        }
    }
}

#Preview("PreviewDocument") {
    PreviewDocument { _ in
        Text("Hello World")
    }
}

#Preview("PreviewDocument: KeyPath") {
    PreviewDocument(keyPath: \.abstract) { abstract in
        InlineContentView(abstract!)
    }
}

import Docsy

class ReferenceResolver {
    let bundleIdentifier: BundleIdentifier

    init(bundleIdentifier: BundleIdentifier) {
        self.bundleIdentifier = bundleIdentifier
    }

    private var references: [String: Reference] = [:]

    func insert(_ references: [String: Reference]) {
        for (id, reference) in references {
            self.insert(reference, forIdentifier: id)
        }
    }

    func insert(_ reference: Reference, forIdentifier id: String) {
        self.references[id] = reference
    }
}

protocol ReferenceResolverProtocol {
    func resolve(_ identifier: ReferenceIdentifier) -> Reference
}

extension ReferenceResolverProtocol {
    subscript(_ id: ReferenceIdentifier) -> Reference? {
        return resolve(id)
    }
}

@Observable
public class DocumentReferenceResolver {
    private var references: [ReferenceIdentifier: Reference]

    init(references: [ReferenceIdentifier : Reference]) {
        self.references = references
    }

    public subscript(_ id: ReferenceIdentifier) -> Reference? {
        access(keyPath: \.references[id])
        return references[id]
    }
}



extension PreviewDocument {
    static func primaryBlockContent(
        at path: String,
        @ViewBuilder content: @escaping ([BlockContent]) -> Content
    ) -> PreviewDocument {
        PreviewDocument(path) { document in
            let blockContent: [BlockContent] = document.primaryContentSections.flatMap({ primarySection in
                switch primarySection {
                case .content(let content): content.content
                case .discussion(let discussion): discussion.content
                default: [BlockContent]()
                }
            }).map({ content in
                content
            })

            content(blockContent)
        }
    }
}
