import Foundation
import DocCViewer
import Docsy

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

        switch kind {
        case .documentation, .tutorial: url.append(component: "index.html")
        default: break
        }

        do {
            var data = try await context.contentsOfURL(url)
            if [BundleAssetKind.documentation, .tutorial].contains(kind) {
                var string = String(data: data, encoding: .utf8)!
                let baseURI = "doc://\(identifier)/"
                string.replace("var baseUrl = \"/\";", with: "var baseUrl = \"\(baseURI)\";", maxReplacements: 1)
                data = string.data(using: .utf8)!
            }
            return data
        } catch {
            throw .loadingFailed(error)
        }
    }
}
