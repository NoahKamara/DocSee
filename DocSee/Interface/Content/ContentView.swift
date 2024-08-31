import SwiftUI
import Docsy


//extension Document.ReferenceHierarchy {
//    static var preview: Self {
//        Self.init(paths: [[
//            "doc://slothcreatorbuildingdoccdocumentationinxcode.SlothCreator/documentation/SlothCreator",
//            "doc://slothcreatorbuildingdoccdocumentationinxcode.SlothCreator/documentation/SlothCreator/CareSchedule",
//            "doc://slothcreatorbuildingdoccdocumentationinxcode.SlothCreator/documentation/SlothCreator/CareSchedule/Event"
//        ]])
//    }
//}
//
//#Preview {
//    HierarchyView(hierarchy: .reference(.preview))
//}

struct BlockContentsView: View {
    let contents: [BlockContent]

    init(_ contents: [BlockContent]) {
        self.contents = contents
    }

    var body: some View {
        ForEach((0..<contents.count).map({ $0 }), id:\.self) { i in
            BlockContentView(contents[i])
        }
    }
}
struct BlockContentView: View {
    let content: BlockContent

    init(_ content: BlockContent) {
        self.content = content
    }

    var body: some View {
        switch content {
        case .paragraph(let paragraph):
            InlineContentView(paragraph.inlineContent)
        case .aside(let aside):
            AsideView(aside)
//        case .codeListing(let codeListing):
//            <#code#>
//        case .heading(let heading):
//            <#code#>
//        case .orderedList(let orderedList):
//            <#code#>
        default: Text("H")
        }
    }
}




struct ContentSectionView: View {
    let section: AnyContentSection

    var body: some View {
        switch section {
        case .discussion(let contentSection):
            BlockContentsView(contentSection.content)
        case .content(let contentSection):
            BlockContentsView(contentSection.content)
//            <#code#>
//        case .taskGroup(let taskGroupSection):
//            <#code#>
//        case .relationships(let relationshipsSection):
//            <#code#>
//        case .declarations(let declarationsSection):
//            <#code#>
//        case .parameters(let parametersSection):
//            <#code#>
//        case .attributes(let attributesSection):
//            <#code#>
//        case .properties(let propertiesSection):
//            <#code#>
//        case .restParameters(let rESTParametersSection):
//            <#code#>
//        case .restEndpoint(let rESTEndpointSection):
//            <#code#>
//        case .restBody(let rESTBodySection):
//            <#code#>
//        case .restResponses(let rESTResponseSection):
//            <#code#>
//        case .plistDetails(let plistDetailsSection):
//            <#code#>
//        case .possibleValues(let possibleValuesSection):
//            <#code#>
//        case .mentions(let mentionsSection):
        default:
            Text("Not Implemented \(section)")
        }
    }
}




struct ContentView: View {
    @Environment(DocumentationContext.self)
    private var context

    let reference: TopicReference

    init(reference: TopicReference) {
        self.reference = reference
    }

    @State
    var document: Document? = nil
    @State private var hasWaited = false

    var body: some View {
        Group {
            if let document {
                DocumentView(document)
                    .contentMargins(20, for: .scrollContent)
            } else {
                ProgressView {
                    VStack {
                        Text("Loading Documentation")
                        Text(reference.path)
                        Text(context.bundles[reference.bundleIdentifier]?.displayName ?? reference.bundleIdentifier)
                    }
                }
                .opacity(hasWaited ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: reference.url.absoluteString) {
            let waitTask = Task {
                try await Task.sleep(for: .seconds(0.4))
                self.hasWaited = true
            }
            defer { waitTask.cancel() }

            do {
                try await load()
            } catch let describedError as DescribedError {
                print(describedError.errorDescription)
            } catch {
                print(error)
            }
        }
    }

    func load() async throws {
        let document = try await context.document(for: reference)
        self.document = document
    }
}



