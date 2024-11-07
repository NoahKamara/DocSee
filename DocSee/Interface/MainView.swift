//
//  MainView.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI

actor Box<T>: Sendable {
    var value: T
    
    init(initialValue value: T) {
        self.value = value
    }
}



public extension EnvironmentValues {
    @Entry var documentationWorkspace = DocumentationWorkspace()
}

import DocCViewer
#if canImport(AppKit)
import AppKit
#endif

struct MainView: View {
    @Environment(\.documentationWorkspace)
    private var workspace

    @Environment(DocSeeContext.self)
    var context

    @Bindable
    var navigator = Navigator()

    @Environment(\.supportsMultipleWindows)
    private var supportsMultipleWindows

    var body: some View {
        NavigationSplitView {
            SidebarView(tree: context.tree, navigator: navigator)
                .navigationTitle("DocSee")
                .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: nil)
        } detail: {
            DocumentView(context: context, navigator: navigator)
                .ignoresSafeArea(.all, edges: .bottom)
                .toolbar {
                    if let topic = navigator.selection {
                        if supportsMultipleWindows {
                            ToolbarItem(id: "open-topic-in-window") {
                                TopicActions.OpenWindow(topic)
                            }
                        }
                        
                        ToolbarItem(id: "copy-topic-link") {
                            TopicActions.CopyLink(topic)
                        }
                    }
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
                return .handled
                
            default: return .systemAction
            }
        }))
        .environment(context)
        .task {
            do {
                let bundlePaths = [
                    "docsee/testdocumentation",
                    "docsee/swiftdocc",
                    "docsee/slothcreator",
                ]

                let indexProviders = bundlePaths.map { path in
                    DocSeeIndexProvider(path: path)
                }
                for provider in indexProviders {
                    try await workspace.registerProvider(provider)
                }
            } catch {
                print("Error registering Bundle Provider \(error)")
            }
        }
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
