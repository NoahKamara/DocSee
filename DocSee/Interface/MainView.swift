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

    @Environment(\.debugMode)
    var debugMode

    @Environment(\.supportsMultipleWindows)
    private var supportsMultipleWindows
    
    var body: some View {
        NavigationSplitView {
            SidebarView(tree: context.tree, navigator:    navigator)
                .navigationTitle("DocSee")
        } detail: {
            DocumentView(context: context, navigator: navigator)
                .ignoresSafeArea(.all, edges: .bottom)
                .toolbar {
                    if supportsMultipleWindows {
                        ToolbarItem(id: "open-topic-in-window") {
                            OptionalTopicButton(navigator.selection) { topic in
                                OpenTopicInWindowButton(topic)
                            }
                        }
                    }

                    ToolbarItem(id: "copy-topic-link") {
                        OptionalTopicButton(navigator.selection) { topic in
                            CopyTopicToClipboardButton(topic)
                        }
                    }
                }
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
                print("Error registering Bundle Provider")
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
