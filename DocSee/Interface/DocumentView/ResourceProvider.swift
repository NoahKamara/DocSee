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
    let context: DocumentationContext

    init(context: DocumentationContext) {
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
