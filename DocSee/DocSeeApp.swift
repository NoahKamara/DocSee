//
//  DocSeeApp.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

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
            WindowGroup("DocSee") {
                MainView()
            }

            WindowGroup(id: "secondary", for: TopicReference.self) { $reference in
                DocumentView(context: context, navigator: .init(initialTopic: reference))
#if os(macOS)
    .presentedWindowStyle(.plain)
    .presentedWindowToolbarStyle(.unified)
#endif
            }
#if os(macOS)
            .windowBackgroundDragBehavior(.enabled)
#endif
        }
        .environment(\.documentationWorkspace, workspace)
        .environment(context)
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

struct AppBundleDataProvider: DataProvider {
    let identifier: String
    let fileSystemProvider: LocalFileSystemDataProvider

    init(bundle: Bundle, path: String? = nil) throws {
        let bundleId = bundle.bundleIdentifier ?? "unknown"

        self.identifier = "com.docsee.bundle.\(bundleId).\(UUID().uuidString)"

        guard var resourceURL = bundle.resourceURL else {
            throw BundleDataProviderError.noResoureURL(
                bundle.bundleIdentifier ?? bundle.description
            )
        }

        if let path {
            resourceURL.append(path: path)
        }

        self.fileSystemProvider = try LocalFileSystemDataProvider(
            rootURL: resourceURL,
            allowArbitraryCatalogDirectories: true
        )
    }

    func contentsOfURL(_ url: URL) throws -> Data {
        try fileSystemProvider.contentsOfURL(url)
    }

    func bundles() throws -> [DocumentationBundle] {
        try fileSystemProvider.bundles()
    }
}
