//
//  SourceBrowser.swift
//  DocSee
//
//  Created by Noah Kamara on 09.11.24.
//

import SwiftUI
import Docsy

struct SourceCreateView<Content: View>: View {
    typealias OpenPreviewAction = (Project.Bundle) -> Void
    
    @ViewBuilder
    var content: (@escaping OpenPreviewAction) -> Content
    
    @State
    var previewBundle: Project.Bundle? = nil
    
    var body: some View {
//        content({
//            openPreview($0)
//        })
        Text("HI")
    }
    
    func openPreview(_ bundle: Project.Bundle) {
        self.previewBundle = bundle
    }
}

#Preview {
//    SourceCreateView { previewBundle in
//        Text("HI")
//        //        HTTPSourceCreateView(didSubmit: { previewBundle($0) })
//    }
    Text("HII")
}


struct BundlePreview: View {
    let bundle: Project.Bundle
    
    var body: some View {
        HStack(alignment: .top) {
            switch bundle.source.kind {
            case .localFS: PageTypeIcon(.symbol("folder"))
            case .index: PageTypeIcon(.symbol("magnifyingglass"))
            case .http: PageTypeIcon(.symbol("network"))
            }
            
            VStack(alignment: .leading) {
                Text(bundle.metadata.displayName)
                Text(bundle.metadata.identifier)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

//#Preview {
//    let metadata = DocumentationBundle.Metadata(
//        displayName: "Retry",
//        identifier: "com.example.retry"
//    )
//    
//    let httpSource = DocumentationSource.HTTP(
//        baseURL: URL(string: "https://swiftpackageindex.com/ph1ps/swift-concurrency-retry/0.0.1")!,
//        indexPath: "index",
//        metadata: metadata
//    )
//    
//    BundlePreview(bundle: .init(source: .http(httpSource), metadata: metadata))
//}

struct BundleBrowserView: View {
    let didSubmit: (Project.Bundle) async throws -> Void
    
    @State
    private var bundle: Project.Bundle? = nil
    
    @State
    var sourceKind: DocumentationSource.Kind = .http
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        Form {
            Picker("Source", selection: $sourceKind) {
                Text("Select Source")
                    .tag(DocumentationSource.Kind?.none)
                    .disabled(true)
                Text("HTTP").tag(DocumentationSource.Kind.http)
                Text("DocSee Index").tag(DocumentationSource.Kind.index)
                Text("Local FileSystem").tag(DocumentationSource.Kind.localFS)
            }
            
            if let bundle {
                Section {
                    BundlePreview(bundle: bundle)
                }
                
                Section("Validation") {
                    LabeledContent("Documentation Index") {
                        switch indexValidation {
                        case .none: ProgressView()
                        case .success:
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        case .failed(let reason):
                            Text(reason ?? "invalid")
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                
                AsyncButton("Add '\(bundle.metadata.displayName)'") {
                    do {
                        guard await validateBundle(bundle) == .success else {
                            return
                        }
                        try await didSubmit(bundle)
                        
                        dismiss()
                    } catch {
                        print("error", error)
                        throw error
                    }
                }
            } else {
                switch sourceKind {
                case .localFS:
                    Text("Not Implemented")
                case .index:
                    Text("Not Implemented")
                case .http:
                    HTTPSourceCreateView { bundle in
                        validate(bundle)
                    }
                }
            }
        }
        .presentationDetents(bundle == nil ? [.medium, .large] : [.fraction(0.3)])
    }
    
    func validate(_ bundle: Project.Bundle) {
        self.bundle = bundle
        
        self.validationTask?.cancel()
        self.validationTask = Task {
            let result = await self.validateBundle(bundle)
            self.indexValidation = result
        }
    }
    
    @State
    private var indexValidation: ValidatationResult? = nil
    @State
    private var validationTask: Task<Void, Never>? = nil
    
    func validateBundle(_ bundle: Project.Bundle) async -> ValidatationResult? {
        do {
            let provider = try PersistableDataProvider(source: bundle.source)
            
            guard let bundle = try await provider.bundles().first else {
                return .failed("internal: failed to discover bundle")
            }
            
            do {
                let indexData = try await provider.contentsOfURL(bundle.indexURL)
                do {
                    _ = try JSONDecoder().decode(DocumentationIndex.self, from: indexData)
                } catch {
                    return .failed("invalid data")
                }
            } catch {
                return .failed("could not load index")
            }
        } catch {
            return .failed("internal: failed to create provider")
        }
        
        return .success
    }
}

#Preview {
    BundleBrowserView(didSubmit: { bundle in
        print(bundle)
    })
}
