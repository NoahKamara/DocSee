//
//  ResourceProvider.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import DocCViewer
import Docsy
import Foundation

class DocsyResourceProvider: BundleResourceProvider {
    let context: DocSeeContext

    init(context: DocSeeContext) {
        self.context = context
    }

    func provideAsset(_ kind: BundleAssetKind, forBundle identifier: String, at path: String) async throws(DocsyResourceProviderError) -> Data {
        let urlString = "doc://\(identifier)/\(path)"

        guard var url = URL(string: urlString) else {
            throw .invalidURL(urlString)
        }

        do {
            var data = try await context.contentsOfURL(url)
            return data
        } catch {
            throw .loadingFailed(error)
        }
    }
}

public enum ContextError: Error {
    case unknownBundle(BundleIdentifier)
}

extension DocSeeContext {
    /// Provides contents for the url if the url is a valid url provided by this context
    ///
    /// > only use doc urls
    ///
    /// - Parameter url: a doc url like `doc://<bundle-identifier>/path`
    /// - Returns:
    func contentsOfURL(_ url: URL) async throws -> Data {
        guard url.scheme == "doc" else {
            fatalError("scheme error")
        }

        let (bundleIdentifier, path): (String, String) = if let host = url.host() {
            (host, url.path())
        } else {
            (url.path(), "/")
        }

        do {
            let bundle = try await bundle(for: bundleIdentifier)
            let url = bundle.baseURL.appending(path: path)
            return try await workspace.contentsOfURL(url, in: bundle)
        } catch let error as DescribedError {
            Self.logger.error("failed to load contents for [\(url)]: \(error.errorDescription)")
            throw error
        } catch {
            throw error
        }
    }

    func bundle(for identifier: BundleIdentifier) async throws(ContextError) -> DocumentationBundle {
        guard let bundle = await workspace.bundles[identifier] else {
            throw .unknownBundle(identifier)
        }
        return bundle
    }

    func index(for identifier: BundleIdentifier) async throws -> DocumentationIndex {
        let decoder = JSONDecoder()

        return try await Task.detached {
            let bundle = try await self.bundle(for: identifier)
            let indexData = try await self.workspace.contentsOfURL(bundle.indexURL, in: bundle)
            return try decoder.decode(DocumentationIndex.self, from: indexData)
        }.value
    }
}
