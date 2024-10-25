//
//  DocSeeIndexProvider.swift
//  DocSee
//
//  Created by Noah Kamara on 23.10.24.
//

import Foundation
import Docsy

enum DocseeIndexProviderError: Error {
    case notFound
    case unknown(_ statusCode: Int)
}

public struct DocSeeIndexProvider: DataProvider {
    
    public let identifier: String
    let baseURI: URL
    let urlSession = URLSession.shared
    let path: String
    
    init(
        identifier: String = UUID().uuidString,
        baseURI: URL = URL(string: "http://192.168.1.219:8080")!,
        path: String
    ) {
        self.identifier = identifier
        self.baseURI = baseURI
        self.path = path
    }
    
    
    public func contentsOfURL(_ url: URL) async throws -> Data {
        let requestUrl = baseURI.appending(path: url.path())
        let (data, res) = try await urlSession.data(from: requestUrl)
        
        let urlResponse = res as! HTTPURLResponse
        
        switch urlResponse.statusCode {
        case 200: return data
        case 404: throw DocseeIndexProviderError.notFound
        default: throw DocseeIndexProviderError.unknown(urlResponse.statusCode)
        }
        
//        return data
    }

    public func bundles() async throws -> [DocumentationBundle] {
        let bundleBaseUrl = baseURI.appending(path: self.path)
        
        let metadataUrl = bundleBaseUrl.appending(component: "metadata.json")
        let data = try await contentsOfURL(metadataUrl)
        let decoder = JSONDecoder()
        
        let metadata = try decoder.decode(DocumentationBundle.Metadata.self, from: data)
        
        let bundle = DocumentationBundle(
            info: metadata,
            baseURL: bundleBaseUrl,
            indexURL: bundleBaseUrl.appending(components: "index", "index.json"),
            themeSettings: nil
        )
        return [bundle]
    }
}
