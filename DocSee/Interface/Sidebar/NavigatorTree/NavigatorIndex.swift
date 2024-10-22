//
//  NavigatorTree.swift
//  DocSee
//
//  Created by Noah Kamara on 19.10.24.
//

import Foundation
import Observation
import Docsy
import OSLog

struct DataProviderDescriptor {
    enum Kind {
        case localFS
    }
    
    let id: String
    let kind: Kind
    let metadata: [String:String]
}

struct Workspace {
    let bundles: [BundleIdentifier: DocumentationBundle.Metadata]
    let providers: [String: DataProviderDescriptor]
}

@MainActor
class NavigatorIndex {
    static let logger = Logger(subsystem: "com.noahkamara.docsee", category: "NavigatorIndex")
    
    var tree: NavigatorTree = .preview()
    
    init() {
        self.tree = .init(root: .init(title: "", type: .root))
    }
    
    private func getFirstToplevelNode(where condition: @escaping (NavigatorTree.Node) -> Bool) -> NavigatorTree.Node? {
        tree.root.children.first(where: condition)
    }
    
    public func dataProvider(_ dataProvider: any DocumentationContextDataProvider, didAddBundle bundle: DocumentationBundle) {
        Self.logger.debug("[dataProvider] add bundle '\(bundle.identifier)'")

        
        let existingBundleNode = getFirstToplevelNode(where: {
            $0.reference?.bundleIdentifier == bundle.identifier
        })
        
        // Create new node if not present
        let bundleNode = existingBundleNode ?? addBundleReference(
            bundleIdentifier: bundle.identifier,
            displayName: bundle.displayName
        )
        
        Task {
            let indexData = try await dataProvider.contentsOfURL(bundle.indexURL, in: bundle)
            let index = try JSONDecoder().decode(DocumentationIndex.self, from: indexData)
            didResolveIndex(index, for: bundle)
        }
    }

//    public func dataProvider(_: any DocumentationContextDataProvider, didRemoveBundle bundle: DocumentationBundle) {
//        Self.logger.debug("[dataProvider] remove bundle '\(bundle.identifier)'")
//
//        index.unload(bundle: bundle)
//        withMutation(keyPath: \.bundles) {
//            _ = self.bundles.removeValue(forKey: bundle.identifier)
//        }
//    }
    
    public func addGroupMarker(_ title: String, at offset: Int = 0) {
        let node = NavigatorTree.Node.groupMarker(title)
        self.tree.root.insertChild(node, at: offset)
    }
    @discardableResult
    func addBundleReference(bundleIdentifier: BundleIdentifier, displayName: String) -> NavigatorTree.Node {
        let bundleNode = NavigatorTree.Node(
            title: displayName,
            reference: TopicReference(
                bundleIdentifier: bundleIdentifier,
                path: "",
                sourceLanguage: .swift
            ),
            type: .root,
            children: []
        )
        
        tree.root.insertChild(bundleNode, at: 0)
        return bundleNode
    }
    
    
    func didResolveIndex(_ index: DocumentationIndex, for bundle: DocumentationBundle) {
        let bundleNode = self.tree.root.children.first(where: {
            $0.type == .root && $0.reference == bundle.rootReference
        })
        
        guard let bundleNode else {
            print("bundle not found: \(bundle.identifier)")
            return
        }
        
        for (lang, nodes) in index.interfaceLanguages.values.reversed() {
            let children = nodes.map {
                NavigatorTree.Node(resolving: $0, at: bundle.rootReference)
            }
            print(
                "[\(bundle.identifier)] found language: \(lang.id) with \(nodes[0].title) elements"
            )
            
            
            let langNode = NavigatorTree.Node(
                title: "\(bundle.displayName) (\(lang.name))",
                type: .languageGroup,
                children: children
            )
            
            bundleNode.insertChild(langNode, at: 0)
        }
    }
}


