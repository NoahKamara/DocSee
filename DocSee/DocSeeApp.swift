import Docsy
import SwiftData
import SwiftUI

struct URLBookmark: Codable {
    var data: Data
}

@Model
class DocumentationReference {
    @Attribute(.unique)
    private(set) var identifier: String

    @Attribute(.unique)
    private(set) var displayName: String

    @Attribute(.unique)
    private(set) var url: URL

    public init(identifier: String, displayName: String, url: URL) {
        self.identifier = identifier
        self.displayName = displayName
        self.url = url
    }
}

// @Model
// class Workspace {
//    @Attribute(.unique)
//    private(set) var identifier: String
//
//    @Attribute(.unique)
//    private(set) var displayName: String
//
//    @Attribute(.unique)
//    private(set) var url: URL
//
//    public init(identifier: String, displayName: String, url: URL) {
//        self.identifier = identifier
//        self.displayName = displayName
//        self.url = url
//    }
// }

@main
struct DocSeeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            DocumentationReference.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        Group {
            MainScene()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct MainScene: Scene {
    let workspace: DocumentationWorkspace
    let context: DocumentationContext

    init() {
        let workspace = DocumentationWorkspace()
        self.workspace = workspace
        self.context = DocumentationContext(dataProvider: workspace)
    }

    var body: some Scene {
        Group {
            Window("DocSee", id: "main") {
                MainView(context: context)
            }

            WindowGroup(id: "secondary", for: TopicReference.self) { $reference in
                DocumentView(context: context, navigator: .init(initialTopic: reference))
                    .presentedWindowStyle(.plain)
                    .presentedWindowToolbarStyle(.unified)
            }
            .windowBackgroundDragBehavior(.enabled)
        }
        .environment(\.documentationWorkspace, workspace)
    }
}

import UniformTypeIdentifiers

extension UTType {
    static var doccarchive: UTType {
        .init(importedAs: "com.apple.documentation.archive", conformingTo: .directory)
    }
}

enum BundleDataProviderError: Error {
    case noResoureURL(String)
}

extension LocalFileSystemDataProvider {
    init(bundle: Bundle) throws {
        guard let resourceURL = bundle.resourceURL else {
            throw BundleDataProviderError.noResoureURL(bundle.bundleIdentifier ?? bundle.description)
        }
        try self.init(
            rootURL: resourceURL.appending(components: "TestDocumentation.doccarchive"),
            allowArbitraryCatalogDirectories: false
        )
    }
}
