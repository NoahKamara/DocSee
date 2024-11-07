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
        MainScene()
        .modelContainer(sharedModelContainer)
    }
}

struct MainScene: Scene {
    let workspace: DocumentationWorkspace
    let context: DocSeeContext

    init() {
        let workspace = DocumentationWorkspace()
        self.workspace = workspace
        self.context = DocSeeContext(workspace: workspace)
    }

    var body: some Scene {
        Group {
            WindowGroup("DocSee") {
                MainView()
            }

            WindowGroup(id: "secondary", for: TopicReference.self) { $reference in
                NavigationStack {
                    DocumentView(context: context, navigator: .init(initialTopic: reference))
                        .ignoresSafeArea(.all, edges: .bottom)
                }
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
