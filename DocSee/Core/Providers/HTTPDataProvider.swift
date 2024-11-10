//
//  HTTPDataProvider.swift
//  DocSee
//
//  Created by Noah Kamara on 10.11.24.
//

import Foundation
import Docsy

struct HTTPDataProvider: DataProvider {
    enum ProviderError: Error {
        case urlDenied(URLDenyReason)
        case errorResponse(_ statusCode: Int, _ data: Data)
        case requestError(any Error)
        
        enum URLDenyReason {
            /// The url is not a http or https url
            case scheme
            
            /// the url does not share the same base as this dataprovider
            case base
        }
    }
    
    let urlSession: URLSession
    let identifier: String
    
    let baseURL: URL
    let indexURL: URL
    
    enum MetadataSource {
        case url(URL)
        case constant(DocumentationBundle.Metadata)
    }
    
    let metadataSource: MetadataSource
    
    init(
        urlSession: URLSession = .shared,
        identifier: String? = nil,
        baseURL: URL,
        indexURL: URL,
        metadataSource: MetadataSource
    ) {
        self.urlSession = urlSession
        self.identifier = identifier ?? UUID().uuidString
        self.baseURL = baseURL
        self.indexURL = indexURL
        self.metadataSource = metadataSource
    }
    
    func contentsOfURL(
        _ url: URL
    ) async throws(ProviderError) -> Data {
        print("HTTP", url)
        guard ["http", "https"].contains(url.scheme) else {
            throw .urlDenied(.scheme)
        }
        
        guard url.absoluteString.hasPrefix(baseURL.absoluteString) else {
            throw .urlDenied(.base)
        }
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            let httpResponse = response as! HTTPURLResponse
            
            guard 200..<300 ~= httpResponse.statusCode else {
                throw ProviderError.errorResponse(httpResponse.statusCode, data)
            }
            
            return data
        } catch {
            throw ProviderError.requestError(error)
        }
    }
    
    private func createMetadata() async throws -> DocumentationBundle.Metadata {
        switch metadataSource {
        case .url(let url):
            let metadataData = try await contentsOfURL(url)
            let metadata = try JSONDecoder().decode(
                DocumentationBundle.Metadata.self,
                from: metadataData
            )
            
            return metadata
        case .constant(let metadata):
            return metadata
        }
    }
    func createBundle() async throws -> DocumentationBundle {
        let metadata = try await createMetadata()
        
        return DocumentationBundle(
            info: metadata,
            baseURL: baseURL,
            indexURL: indexURL,
            themeSettings: nil
        )
    }
    
    
    func bundles() async throws -> [DocumentationBundle] {
        return [try await createBundle()]
    }
}
