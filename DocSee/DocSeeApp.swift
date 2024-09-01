import SwiftUI
import SwiftData
import Docsy


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

//@Model
//class Workspace {
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
//}


@main
struct DocSeeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            DocumentationReference.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    let workspace = DocumentationWorkspace()

    var body: some Scene {
        WindowGroup {
            MainView(context: DocumentationContext(dataProvider: workspace))
        }
        .environment(\.documentationWorkspace, workspace)
        .modelContainer(sharedModelContainer)
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

//public struct DoccArchiveDropDelegate: DropDelegate, ViewModifier {
//    @State
//    var isEntered: Bool = false
//
//    @Environment(DocumentationWorkspace.self)
//    private var workspace
//
//    let allowedContentTypes: [UTType] = [
//        .doccarchive,
//        .directory,
////        .url,
////        .fileURL
//    ]
//
//    public func body(content: Content) -> some View {
//        content
//            .onDrop(of: allowedContentTypes, delegate: self)
//    }
//
//    public func validateDrop(info: DropInfo) -> Bool {
//        print("validate", info)
//        let providers = info.itemProviders(for: allowedContentTypes)
//
//        for provider in providers {
//            print(provider.load)
//        }
//        return info.hasItemsConforming(to: allowedContentTypes)
//    }
//
//    public  func performDrop(info: DropInfo) -> Bool { false }
//
//    public func dropEntered(info: DropInfo) {
//        print("entered")
//    }
//
//    public func dropUpdated(info: DropInfo) -> DropProposal? {
////        print("updated")
//        self.isEntered = true
//        return .init(operation: .copy)
//    }
//
//    public func dropExited(info: DropInfo) {
//        self.isEntered = false
//    }
//}
//
//extension View {
//    func docsyDropDelegate() -> some View {
//        self.modifier(DoccArchiveDropDelegate())
//    }
//}



