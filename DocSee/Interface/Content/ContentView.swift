import SwiftUI
import Docsy


struct BlockContentsView: View {
    let contents: [BlockContent]

    init(_ contents: [BlockContent]) {
        self.contents = contents
    }

    var body: some View {
        VStack(alignment: .leading) {
            ForEach((0..<contents.count).map({ $0 }), id:\.self) { i in
                BlockContentView(contents[i])
            }
        }
    }
}


fileprivate struct BlockContentView: View {
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
        case .codeListing(let codeListing):
            CodeListingView(codeListing)
        case .heading(let heading):
            HeadingView(heading)
        case .orderedList(let orderedList):
            OrderedListView(list: orderedList)
        case .unorderedList(let unorderedList):
            UnorderedListView(list: unorderedList)
        case .termList(let termList):
            TermListView(list: termList)
        default: Text("H")
        }
    }
}


struct HeadingView: View {
    let heading: BlockContent.Heading

    init(_ heading: BlockContent.Heading) {
        self.heading = heading
    }

    func font(for level: Int) -> Font {
        switch level {
        case 1: Font.largeTitle
        case 2: Font.title
        case 3: Font.title2
        case 4: Font.title3
        case 5: Font.headline
        /* case 6 */ default: Font.subheadline
        }
    }

    func padding(for level: Int) -> CGFloat {
        switch level {
        case 1: 20
        case 2: 10
        case 3: 10
        case 4: 10
        case 5: 10
        /* case 6 */ default: 10
        }
    }

    var body: some View {
        Group {
            if let anchor = heading.anchor {
                Text(heading.text)
                    .tag(anchor)
            } else {
                Text(heading.text)
            }
        }
        .headerProminence(.increased)
        .font(font(for: heading.level))
        .padding(.top, padding(for: heading.level))
    }
}

#Preview("Heading") {
    VStack(alignment: .leading) {
        ForEach(1..<7) { level in
            HeadingView(.init(
                level: level,
                text: "Heading \(level)",
                anchor: "heading-\(level)"
            ))
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

#Preview {
    PreviewDocument("/documentation/testdocumentation/markdown") { document in
        DocumentView(document)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
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



