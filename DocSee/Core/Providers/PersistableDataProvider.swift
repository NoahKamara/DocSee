//
//  PersistableDataProvider.swift
//  DocSee
//
//  Created by Noah Kamara on 10.11.24.
//

import Foundation
import Docsy

final class PersistableDataProvider: Sendable, DataProvider, Codable {
    enum SetupError: Error {
        case setupFailure(Error)
    }

    let identifier: String
    let source: DocumentationSource
    private let provider: DataProvider

    init(
        source: DocumentationSource
    ) throws(SetupError) {
        self.identifier = UUID().uuidString
        self.source = source
        self.provider = try loadProvider(source)
    }

    func contentsOfURL(_ url: URL) async throws -> Data {
        try await provider.contentsOfURL(url)
    }

    func bundles() async throws -> [Docsy.DocumentationBundle] {
        return try await provider.bundles()
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = UUID().uuidString
        self.source = try container.decode(DocumentationSource.self, forKey: .source)
        self.provider = try loadProvider(source)
    }

    enum CodingKeys: CodingKey {
        case source
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
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
        case .http(let http): HTTPDataProvider(
            baseURL: http.baseURL,
            indexURL: http.indexUrl,
            metadataSource: http.metadata
                .map({ .constant($0) }) ??
                .url(http.baseURL.appendingPathComponent("metadata.json"))
        )
        }
    } catch {
        throw .setupFailure(error)
    }
}

