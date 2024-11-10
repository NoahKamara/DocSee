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


struct InspectorSidebar: View {
    var tree: NavigatorTree

    var navigator: Navigator
    
    static let collapsedDetent = PresentationDetent.height(80)
    
    @State
    private var detent: PresentationDetent = Self.collapsedDetent
    
    var body: some View {
        NavigationStack {
            SidebarView(tree: tree, navigator: navigator)
        }
        .presentationBackground(content: {
            Color.green
        })
        .presentationDetents([Self.collapsedDetent, .medium, .large], selection: $detent)
        .interactiveDismissDisabled(true)
        .presentationContentInteraction(detent == Self.collapsedDetent ? .resizes : .scrolls)
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        .presentationCornerRadius(30)
        .overlay {
            Group {
                if detent == Self.collapsedDetent {
                    ZStack {
                        Rectangle()
                            .fill(.regularMaterial)
                            .frame(maxHeight: .infinity)
                            .ignoresSafeArea(.all, edges: .bottom)
                        
                        Button("Show Navigator", action: { detent = .medium })
                            .frame(height: 80)
                    }
                }
            }
        }
    }
}

struct MainView: View {
    @Environment(\.documentationWorkspace)
    private var workspace

    @Environment(DocSeeContext.self)
    var context

    @Bindable
    var navigator = Navigator()

    @Environment(\.supportsMultipleWindows)
    private var supportsMultipleWindows

#if os(iOS)
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
#endif
    
    @State
    var isShowingInspector: Bool = true
    
    var body: some View {
        Group {
#if os(iOS)
        if horizontalSizeClass == .compact {
            NavigationStack {
                detail
                    .toolbar(content: {
                        ToolbarItem(placement: .bottomBar) {
                            Button(action: { isShowingInspector.toggle() }) {
                                Image(systemName: "list.dash.header.rectangle")
                            }
                        }
                    })
                    .inspector(isPresented: .constant(true)) {
                        InspectorSidebar(tree: context.tree, navigator: navigator)
                    }
            }
        } else {
            NavigationSplitView {
                sidebar
            } detail: {
                detail
            }
        }
#else
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
#endif
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
                    "docsee/ArgumentParser.doccarchive"
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
    
    var sidebar: some View {
        SidebarView(tree: context.tree, navigator: navigator)
            .navigationTitle("DocSee")
            .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: nil)
            .listStyle(.sidebar)
    }
    
    var detail: some View {
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
