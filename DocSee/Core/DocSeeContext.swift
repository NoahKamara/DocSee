//
//  DocSeeContext.swift
//  DocSee
//
//  Created by Noah Kamara on 07.11.24.
//

import Foundation
import Docsy
import OSLog

@Observable
final class DocSeeContext: Sendable, DocumentationContextDataProviderDelegate {
    static let logger = Logger(subsystem: "com.noahkamara.docsee", category: "Context2")

    let workspace: DocumentationWorkspace

    var tree: NavigatorTree

    private var project: Project

    init(workspace: DocumentationWorkspace) {
        self.workspace = workspace
        self.project = Project(
            items: [],
            references: [:]
        )
        self.tree = NavigatorTree()
        workspace.delegate = self
    }

    func load(_ newProject: Project) async throws {
        if project.isPersistent {
            try await project.save()
        }

        let children = newProject.items.map { item in
            switch item {
            case .bundle(let bundleIdentifier):
                bundleReference(metadata: project.references[bundleIdentifier]!.metadata)

            case .groupMarker(let displayName):
                NavigatorTree.Node(
                    title: displayName,
                    type: .groupMarker,
                    children: []
                )
            }
        }

        withMutation(keyPath: \.project) {
            self.project = project
        }

        withMutation(keyPath: \.tree) {
            tree.root.replaceChildren(with: children)
        }
    }

    func save() async throws {
        project.items = tree.root.children.map { page in
            if let topic = page.reference {
                Project.ProjectNode.bundle(topic.bundleIdentifier)
            } else {
                Project.ProjectNode.groupMarker(page.title)
            }
        }
        try await project.save()
    }

    /// Add a bundle to the project
    /// - Parameters:
    ///   - displayName: display name for the bundle
    ///   - bundleIdentifier: unique identifier for the bundle
    ///   - source: Source for the bundle
    func addBundle(
        displayName: String,
        bundleIdentifier: BundleIdentifier,
        source: DocumentationSource
    ) async throws {
        let provider = try PersistableDataProvider(source: source)

        let bundle = Project.Bundle(
            source: source,
            metadata: .init(displayName: displayName, identifier: bundleIdentifier)
        )

        project.references[bundleIdentifier] = bundle

        if tree.getBundleNode(with: bundleIdentifier) == nil {
            let node = bundleReference(metadata: .init(displayName: displayName, identifier: bundleIdentifier))
            tree.root.insertChild(node, at: 0)
        }

        try await workspace.registerProvider(provider)
    }

    // MARK: DocumentationContextDataProviderDelegate
    func dataProvider(
        _ dataProvider: any Docsy.DocumentationContextDataProvider,
        didAddBundle bundle: Docsy.DocumentationBundle
    ) {
        Self.logger.debug("add bundle '\(bundle.identifier)'")

        let existingBundleNode = tree.getBundleNode(with: bundle.identifier)

        if existingBundleNode == nil {
            let newNode = bundleReference(metadata: bundle.metadata)
            tree.root.insertChild(newNode, at: 0)
        }

        Task {
            let indexData = try await dataProvider.contentsOfURL(bundle.indexURL, in: bundle)
            let index = try JSONDecoder().decode(DocumentationIndex.self, from: indexData)
            didResolveIndex(index, for: bundle)
        }
    }

    func dataProvider(
        _ dataProvider: any Docsy.DocumentationContextDataProvider,
        didRemoveBundle bundle: Docsy.DocumentationBundle
    ) {}

    func didResolveIndex(_ index: DocumentationIndex, for bundle: DocumentationBundle) {
        let bundleNode = tree.root.firstChild(where: {
            $0.type == .root && $0.reference == bundle.rootReference
        })

        guard let bundleNode else {
            print("bundle not found: \(bundle.identifier)")
            return
        }

        let bundleContent = index.interfaceLanguages.values.reversed().map { lang, nodes in
            let children = nodes.map {
                NavigatorTree.Node(resolving: $0, at: bundle.rootReference)
            }
            print(
                "[\(bundle.identifier)] found language: \(lang.id) with \(nodes.count) elements"
            )

            return NavigatorTree.Node(
                title: lang.name,
                type: .languageGroup,
                children: children
            )
        }

        bundleNode.replaceChildren(with: bundleContent)
    }
}


private extension NavigatorTree {
    func getBundleNode(with bundleIdentifier: BundleIdentifier) -> Node? {
        root.firstChild(where: {
            $0.type == .root && $0.reference?.bundleIdentifier == bundleIdentifier
        })
    }
}


private func bundleReference(metadata: DocumentationBundle.Metadata) -> NavigatorTree.Node {
    let bundleNode = NavigatorTree.Node(
        title: metadata.displayName,
        reference: TopicReference(
            bundleIdentifier: metadata.identifier,
            path: "",
            sourceLanguage: .swift
        ),
        type: .root,
        children: []
    )

    return bundleNode
}

