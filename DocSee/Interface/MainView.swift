//
//  MainView.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

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

struct MainView: View {
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
                .navigationTitle("DocSee")
        } detail: {
            DocumentView(context: context, navigator: navigator)
        }
        .toolbar {
            ToolbarItem(placement: .debugBar) {
                DebugModeButton()
            }
        }
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
