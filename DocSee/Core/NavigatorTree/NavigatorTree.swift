//
//  NavigatorTree.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import Foundation
import Observation

enum DocumentationSource: Codable, Sendable {
    case localFS(LocalFS)
    case index(DocSeeIndex)
    
    struct DocSeeIndex: Codable {
        let path: String
    }

    struct LocalFS: Codable, Sendable {
        let rootURL: URL
    }
}

private func loadProvider(_ source: DocumentationSource) throws(PersistableDataProvider.SetupError) -> DataProvider {
    do {
        return switch source {
        case .localFS(let localFS): try LocalFileSystemDataProvider(
                rootURL: localFS.rootURL,
                allowArbitraryCatalogDirectories: true
            )
        case .index(let index): DocSeeIndexProvider(path: index.path)
        }
    } catch {
        throw .setupFailure(error)
    }
}

final class PersistableDataProvider: Sendable, DataProvider, Codable {
    enum SetupError: Error {
        case setupFailure(Error)
    }

    var identifier: String { bundleIdentifier }
    let bundleIdentifier: BundleIdentifier
    let source: DocumentationSource
    private let provider: DataProvider

    init(
        bundleIdentifier: String = UUID().uuidString,
        source: DocumentationSource
    ) throws(SetupError) {
        self.bundleIdentifier = bundleIdentifier
        self.source = source
        self.provider = try loadProvider(source)
    }

    func contentsOfURL(_ url: URL) async throws -> Data {
        try await provider.contentsOfURL(url)
    }

    func bundles() async throws -> [Docsy.DocumentationBundle] {
        let bundle = try await provider.bundles().first(
            where: { $0.identifier == bundleIdentifier
            })

        // return only the specified bundle
        return bundle.map { [$0] } ?? []
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bundleIdentifier = try container.decode(String.self, forKey: .bundleIdentifier)
        self.source = try container.decode(DocumentationSource.self, forKey: .source)
        self.provider = try loadProvider(source)
    }

    enum CodingKeys: CodingKey {
        case bundleIdentifier
        case source
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encode(source, forKey: .source)
    }
}

@Observable
class Project: Codable {
    struct Bundle: Codable {
        let source: DocumentationSource
        let metadata: DocumentationBundle.Metadata
    }

    class ProjectNode: Identifiable, Codable {
        enum Kind: Codable {
            case bundle
            case groupMarker
        }
        
        let kind: Kind
        let displayName: String
        let reference: String?
        
        
        init(kind: Kind, displayName: String, reference: String?) {
            self.kind = kind
            self.displayName = displayName
            self.reference = reference
        }
        
        public static func groupMarker(title: String) -> ProjectNode {
            ProjectNode(kind: .groupMarker, displayName: title, reference: nil)
        }
        
        public static func bundle(displayName: String, identifier: BundleIdentifier) -> ProjectNode {
            ProjectNode(
                kind: .bundle,
                displayName: displayName,
                reference: identifier
            )
        }
    }

    var displayName: String
    var items: [ProjectNode]
    var references: [BundleIdentifier: Bundle]

    init(
        displayName: String,
        items: [ProjectNode],
        references: [BundleIdentifier: Bundle]
    ) {
        self.displayName = displayName
        self.items = items
        self.references = references
    }

    open func persist() throws {
        return
    }
}



import OSLog

public final class NavigatorTree: Codable {
    public let root: Node

    public init(root: Node) {
        self.root = root
    }

    public init() {
        self.root = Node(title: "", type: .root)
    }

    public init(from decoder: any Decoder) throws {
        self.root = try Node(from: decoder)
    }

    public func encode(to encoder: any Encoder) throws {
        try root.encode(to: encoder)
    }

    public func addGroupMarker(_ title: String, at offset: Int = 0) {
        let node = NavigatorTree.Node.groupMarker(title)
        root.insertChild(node, at: offset)
    }
}

extension NavigatorTree {
    static func preview() -> NavigatorTree {
        let bundle = TopicReference(
            bundleIdentifier: "com.example.bundle",
            path: "",
            sourceLanguage: .swift
        )

        let root = Node.root(
            children: [
                Node.groupMarker("Example Group 1"),
                Node(
                    title: "Example Item A",
                    reference: bundle.appendingPath("example_a"),
                    type: .framework,
                    children: [
                        .init(
                            title: "Some Reference",
                            reference: bundle.appendingPath("some_ref"),
                            type: .article,
                            children: []
                        ),
                    ]
                ),
                Node(
                    title: "Example Item B",
                    reference: bundle.appendingPath("example_b"),
                    type: .framework,
                    children: []
                ),
                Node(
                    title: "Example Item C",
                    reference: bundle.appendingPath("example_c"),
                    type: .framework,
                    children: []
                ),
                Node(
                    title: "Example Item D",
                    reference: bundle.appendingPath("example_d"),
                    type: .framework,
                    children: []
                ),
                Node.groupMarker("Example Group 2"),
            ]
        )

        return NavigatorTree(root: root)
    }
}

// MARK: Node

public extension NavigatorTree {
    @Observable
    class Node: Identifiable, Codable {
        var title: String
        let reference: TopicReference?
        var type: PageType
        private(set) var children: [Node]

        // MARK: INIT

        init(
            title: String,
            reference: TopicReference? = nil,
            type: PageType,
            children: [Node] = []
        ) {
            self.title = title
            self.reference = reference
            self.type = type
            self.children = children
        }

        // MARK: Create

        static func root(children: [Node] = []) -> Node {
            .init(title: "Root", type: .root, children: children)
        }

        static func groupMarker(_ title: String) -> Node {
            .init(title: title, type: .groupMarker, children: [])
        }

        static func leaf(_ title: String, children: [Node]? = nil) -> Node {
            .init(title: title, type: .leaf, children: children ?? [])
        }

        // MARK: Codable

        enum CodingKeys: CodingKey {
            case kind
            case reference
            case title
            case children
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(type, forKey: .kind)
            try container.encode(children, forKey: .children)
        }

        public required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.title = try container.decode(String.self, forKey: .title)
            self.reference = try container
                .decodeIfPresent(TopicReference.self, forKey: .reference)
            self.type = try container.decode(PageType.self, forKey: .kind)
            self.children = try container
                .decodeIfPresent([NavigatorTree.Node].self, forKey: .children) ?? []
        }
    }
}

// MARK: Child Modifications

extension NavigatorTree.Node {
    func firstChild(where condition: @escaping (NavigatorTree.Node) -> Bool) -> NavigatorTree.Node? {
        children.first(where: condition)
    }

    func appendChild(_ node: NavigatorTree.Node) {
        withMutation(keyPath: \.children) {
            children.append(node)
        }
    }

    func insertChild(_ node: NavigatorTree.Node, at offset: Int) {
        withMutation(keyPath: \.children) {
            children.insert(node, at: offset)
        }
    }

    func moveChildren(from indices: IndexSet, to offset: Int) {
        withMutation(keyPath: \.children) {
            children.move(fromOffsets: indices, toOffset: offset)
        }
    }

    func removeAllChildren() {
        withMutation(keyPath: \.children) {
            self.children = []
        }
    }

    func replaceChildren(with collection: [NavigatorTree.Node]) {
        withMutation(keyPath: \.children) {
            self.children = collection
        }
    }

    func deleteChildren(at indices: IndexSet) {
        withMutation(keyPath: \.children) {
            children.remove(atOffsets: indices)
        }
    }
}

// MARK: Resolve from DocumentationIndex

extension NavigatorTree.Node {
    convenience init(resolving node: DocumentationIndex.Node, at rootReference: TopicReference) {
        if let path = node.path {
            let reference = rootReference.appendingPath(path)
            self.init(
                title: node.title,
                reference: reference,
                type: node.type,
                children: node.children?.map {
                    NavigatorTree.Node(resolving: $0, at: rootReference)
                } ?? []
            )
        } else {
            self.init(
                title: node.title,
                reference: nil,
                type: node.type,
                children: []
            )
        }
    }
}

#if DEBUG

// MARK: Debug Tree

extension NavigatorTree.Node: CustomDebugStringConvertible {
    public var debugDescription: String {
        dumpTree()
    }

    func treeLines(prefix: String = "", isLast: Bool = true) -> [String] {
        var line = prefix

        if prefix != "" {
            line += isLast ? "╰─" : "├─"
        }

        line += "[\(type.rawValue)] \(title)"

        return if !children.isEmpty {
            children.enumerated().reduce(into: [line]) { result, element in
                let (index, child) = element
                let newPrefix = prefix + (isLast ? "    " : "│   ")
                result += child.treeLines(prefix: newPrefix, isLast: index == children.count - 1)
            }
        } else {
            [line]
        }
    }

    /// returns a tree representation of this nide
    public func dumpTree() -> String {
        treeLines().joined(separator: "\n")
    }
}

#endif
