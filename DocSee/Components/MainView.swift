import Docsy
import SwiftUI

public extension EnvironmentValues {
    @Entry var documentationWorkspace = DocumentationWorkspace()
}

@propertyWrapper
struct Workspace: DynamicProperty {
    @Environment(\.documentationWorkspace)
    public var wrappedValue

    public init() {}
}

import DocCViewer
#if canImport(AppKit)
import AppKit
#endif

enum Pasteboard {
    static let pasteboard: OSPasteboard = .general

#if os(macOS)
    typealias OSPasteboard = NSPasteboard

    static func setString(_ value: String) {
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
    }

    static func setURL(_ value: URL) {
        pasteboard.clearContents()
        pasteboard.setString(value.absoluteString, forType: .string)
    }

#else
    typealias OSPasteboard = UIPasteboard

    static func setString(_ value: String) {
        pasteboard.setObjects([value])
    }

    static func setURL(_ value: URL) {
        pasteboard.setObjects([value])
    }
#endif
}

struct MainView: View, DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        let urlProviders = info.itemProviders(for: [.url])
        print(urlProviders)
        return true
    }

    @Environment(\.documentationWorkspace)
    private var workspace

    let context: DocumentationContext

    @MainActor
    func load() async {
        do {
            let provider = try LocalFileSystemDataProvider(bundle: .main)
            try await workspace.registerProvider(provider)
        } catch {
            print("Error registering Bundle Provider")
        }
    }

    @Bindable
    var navigator = Navigator()

    @Environment(\.debugMode)
    var debugMode

    var body: some View {
        NavigationSplitView {
            SidebarView(navigator: navigator)
//                .navigationDestination(item: $navigator.selection) { reference in
                ////                    ContentView(reference: reference)
//                    VStack {
//                        Text("Hello")
//
//                    }
//                        .toolbar {
//                            ToolbarItem(placement: .debugBar) {
//                                Menu("Reference") {
//                                    Text("Bundle: \(reference.bundleIdentifier)")
//                                    Text("Path: \(reference.path)")
//                                    if let fragment = reference.fragment {
//                                        Text("Fragment \(fragment)")
//                                    }
//
//                                    Button(action: { Pasteboard.setURL(reference.url) }) {
//                                        Label("Copy URL", systemImage: "link")
//                                    }
//
//                                    Button(action: {
//                                        Pasteboard.setString(reference.url.path())
//                                    }) {
//                                        Label("Copy as Path", systemImage: "questionmark.folder")
//                                    }
//
//                                    Button(action: { Pasteboard.setString(reference.description) }) {
//                                        Label("Copy Topic Reference", systemImage: "chevron.left.forwardslash.chevron.right")
//                                    }
//                                }
//                            }
//                        }
//                }
                .navigationTitle("DocSee")
        } detail: {
            DocumentView2(context: context, navigator: navigator)
        }
        .toolbar(content: {
            ToolbarItem(placement: .debugBar) {
                DebugModeButton()
            }
            ToolbarItemGroup(placement: .navigation) {
                NavigationButtons(navigator: navigator)
            }
        })
        .environment(\.openURL, .init(handler: { url in
            switch url.scheme {
            case "doc":
                navigator.goto(.init(
                    bundleIdentifier: url.host() ?? "",
                    path: url.path(),
                    sourceLanguage: .swift
                ))
                return .discarded
            default: return .systemAction
            }
        }))
//        .toolbarVisibility(debugMode.isDebugging ? .hidden : .automatic, for: .accessoryBar(id: "debug"))
        .environment(context)
        .task {
            await load()
        }
//        .task {
//            let baseURI = URL(filePath: "/Users/noahkamara/Developer/DocSee/")
//
//            do {
//                let doccProvider = try LocalFileSystemDataProvider(
//                    rootURL: baseURI.appending(component: "docc.doccarchive")
//                )
//
//
//                let slothcreatorProvider = try LocalFileSystemDataProvider(
//                    rootURL: baseURI.appending(component: "SlothCreator.doccarchive")
//                )
//
        ////                try await workspace.registerProvider(doccProvider)
//                try await workspace.registerProvider(slothcreatorProvider)
//            } catch let desribedError as DescribedError {
//                print(desribedError.errorDescription)
//            } catch {
//                print(error)
//            }
//        }
    }
}

// #Preview(traits: .workspace) {
//    MainView()
// }

// #Preview {
//    ContentView2()
// }

extension ToolbarItemPlacement {
#if os(macOS)
    static let debugBar = accessoryBar(id: "debugBar")
#else
    static let debugBar = topBarTrailing
#endif
}

enum DocsyResourceProviderError: Error {
    case invalidURL(String)
    case loadingFailed(any Error)
}

import BundleAppSourceProvider

class DocsyResourceProvider: ResourceProvider {
    let context: DocumentationContext

    init(context: DocumentationContext) {
        self.context = context
    }

    func provideAsset(_ kind: BundleAssetKind, forBundle identifier: String, at path: String) async throws(DocsyResourceProviderError) -> Data {
        print("ASSET")
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
                print(string)
                data = string.data(using: .utf8)!
            }
            return data
        } catch {
            throw .loadingFailed(error)
        }
    }

    func provideSource(_ kind: AppSourceKind, at path: consuming String) async throws(DocsyResourceProviderError) -> Data {
//        do {
//            return try await appBundleProvider.provideSource(kind, at: path)
//        } catch {
        throw .invalidURL("not implemented")
//        }
    }
}

import UniformTypeIdentifiers

struct DocumentView2: View {
    @Environment(DocumentationContext.self)
    private var context

    let navigator: Navigator

    @State
    var viewer: DocumentationViewer

    init(context: DocumentationContext, navigator: Navigator) {
        let bundleProvider = DocsyResourceProvider(context: context)
        let provider = BundleAppSourceProvider(bundleProvider: bundleProvider)
        self.viewer = DocumentationViewer(provider: provider)
        self.navigator = navigator
    }

    var body: some View {
        DocumentationView(viewer: viewer)
            .onChange(of: navigator.selection) { _, newValue in
                guard let newValue else { return }
                viewer.load(.init(bundleIdentifier: newValue.bundleIdentifier, path: newValue.path))
            }
    }
}
