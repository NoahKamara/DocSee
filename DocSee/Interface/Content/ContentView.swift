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
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading) {
                        ContentHeaderView(document: document)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
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



