//
//  AppBundle.swift
//  DocSee
//
//  Created by Noah Kamara on 07.11.24.
//

import Docsy
import UniformTypeIdentifiers

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

extension UTType {
    static var doccarchive: UTType {
        .init(importedAs: "com.apple.documentation.archive", conformingTo: .directory)
    }
}

enum BundleDataProviderError: Error {
    case noResoureURL(String)
}

