import SwiftUI
import Docsy

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
                Text("DOC")
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

