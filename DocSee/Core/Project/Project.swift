//
//  Project.swift
//  DocSee
//
//  Created by Noah Kamara on 10.11.24.
//

import Foundation
import Observation
import Docsy

@Observable
class Project: Codable {
    struct Bundle: Codable, Identifiable {
        var id: String { metadata.identifier }
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


enum DocumentationSource: Codable, Sendable {
    case localFS(LocalFS)
    case index(DocSeeIndex)
    case http(HTTP)
    
    var kind: Kind {
        switch self {
        case .localFS: .localFS
        case .index: .index
        case .http: .http
        }
    }
    
    enum Kind: String, Codable {
        case localFS
        case index
        case http
    }
    
    struct DocSeeIndex: Codable {
        let path: String
    }

    struct LocalFS: Codable, Sendable {
        let rootURL: URL
    }
    
    struct HTTP: Codable, Sendable {
        let baseURL: URL
        let indexUrl: URL
        let metadata: DocumentationBundle.Metadata?
        
        
        init(baseURL: URL, indexUrl: URL, metadata: DocumentationBundle.Metadata?) {
            self.baseURL = baseURL
            self.indexUrl = indexUrl
            self.metadata = metadata
        }
        
        
        init(baseURL: URL, indexPath: String, metadata: DocumentationBundle.Metadata?) {
            self.baseURL = baseURL
            self.indexUrl = baseURL.appending(path: indexPath)
            self.metadata = metadata
        }
    }
    
    enum CodingKeys: CodingKey {
        case kind
        case config
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        
        let config: any Encodable = switch self {
        case .localFS(let localFS): localFS
        case .index(let docSeeIndex): docSeeIndex
        case .http(let http): http
        }
        
        try container.encode(config, forKey: .config)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let kind = try container.decode(Kind.self, forKey: .kind)
        
        self = switch kind {
        case .localFS:
            try .localFS(container.decode(DocumentationSource.LocalFS.self, forKey: .config))
        case .index:
            try .index(container.decode(DocumentationSource.DocSeeIndex.self, forKey: .config))
        case .http:
            try .http(container.decode(DocumentationSource.HTTP.self, forKey: .config))
        }
    }
}


