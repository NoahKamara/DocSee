import Foundation
import Docsy

//struct AppleDeveloperDataProvider: DataProvider {
//    let identifier: String = "com.apple.documentation"
//    let session: URLSession = .shared
//
//    func bundles() async throws -> [DocumentationBundle] {
//        let (data, _) = try await session.data(from: URL(string: "https://developer.apple.com/tutorials/data/documentation/technologies.json")!)
//    }
//}

import DocsySchema

// Technology
// https://developer.apple.com/tutorials/data/documentation/technologies.json

/// - [ ] Implement Apple Developer Provider
///     - [ ] Decode Technologies & Technology
/// - [ ] UI
/// - [ ] Implement Symbol Page
/// - [ ] Implement Safe References
typealias TODO = String

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let index = try? JSONDecoder().decode(Index.self, from: jsonData)

import Foundation

// MARK: - Index
public struct Technologies: Decodable {
    /// The current version of the document schema.
    public let schemaVersion: SemanticVersion

    /// The identifier of the document.
    ///
    /// > The identifier of a document is typically the same as the documentation node it's representing.
    public let identifier: TopicReference

    /// The kind of this documentation node.
    public let kind: String = "technologies"

    /// The references used in the document. These can be references to other nodes, media, and more.
    ///
    /// The key for each reference is the ``ReferenceIdentifier/identifier`` of the reference's ``RenderReference/identifier``.
    public let references: [ReferenceIdentifier: Reference]

    /// Hierarchy information about the context in which this documentation node is placed.
    public let hierarchy: Hierarchy?

    /// Arbitrary metadata information about the document.
    public let metadata: Metadata

    public let sections: [Section]
    public let diffAvailability: DiffAvailability
    public let legalNotices: LegalNotices

    init(
        schemaVersion: SemanticVersion,
        identifier: TopicReference,
        references: [ReferenceIdentifier : Reference],
        hierarchy: Hierarchy?,
        metadata: Metadata,
        sections: [Section],
        diffAvailability: DiffAvailability,
        legalNotices: LegalNotices
    ) {
        self.schemaVersion = schemaVersion
        self.identifier = identifier
        self.references = references
        self.hierarchy = hierarchy
        self.metadata = metadata
        self.sections = sections
        self.diffAvailability = diffAvailability
        self.legalNotices = legalNotices
    }
}

public extension Document {
    typealias Section = String
}
public extension Technologies {
    typealias Hierarchy = Document.Hierarchy
    typealias Section = Document.Section
    typealias Metadata = Document.Metadata
}

// MARK: - LegalNotices
public struct LegalNotices: Decodable {
    public let copyright: String
    public let termsOfUse: String
    public let privacyPolicy: String

    public init(copyright: String, termsOfUse: String, privacyPolicy: String) {
        self.copyright = copyright
        self.termsOfUse = termsOfUse
        self.privacyPolicy = privacyPolicy
    }
}

// MARK: - Section
public struct TechnologiesSection: Decodable {
    public let groups: [Group]

    public init(groups: [Group]) {
        self.groups = groups
    }
}

extension TechnologiesSection {
    // MARK: - Group
    public struct Group: Decodable {
        public let name: String
        public let technologies: [Technology]

        public init(name: String, technologies: [Technology]) {
            self.name = name
            self.technologies = technologies
        }
    }
}


// MARK: - Technology
public struct Technology: Decodable {
    public let destination: Reference
    public let title: String
    public let tags: [String]
    public let content: [InlineContent]?

    public let languages: [SourceLanguage]

    public init(
        destination: Reference,
        title: String,
        tags: [String],
        content: [InlineContent],
        languages: [SourceLanguage]
    ) {
        self.destination = destination
        self.title = title
        self.tags = tags
        self.content = content
        self.languages = languages
    }
}

// MARK: - Destination
public struct Destination: Decodable {
    /// The identifier of the destinations reference
    public let identifier: ReferenceIdentifier

    public init(identifier: ReferenceIdentifier) {
        self.identifier = identifier
    }
}


