//
//  DocumentView.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import DocCViewer
import Docsy
import SwiftUI
import UniformTypeIdentifiers
import BundleAppSourceProvider

extension ThemeSettings {
    static let docsee: ThemeSettings = {
        var settings = ThemeSettings()
//        settings.features.docs.i18n.enable()
        settings.features.docs.quickNavigation.enable()
        
        settings.theme.aside.borderRadius = "30rem"
        
        var color = settings.theme.color
        
        color.fill = .pair(
            light: "#FFFFFF",
            dark: "#1D1D1D"
        )
        
        color.fillSecondary = .pair(
            light: "#FFFFFF",
            dark: "#292A30"
        )
        
        settings.theme.color = color
        
        print(settings.description)
        return settings
    }()
}
struct DocumentView: View {
    let navigator: Navigator

    @State
    var viewer: DocumentationViewer

    init(context: DocSeeContext, navigator: Navigator) {
        let bundleProvider = DocsyResourceProvider(context: context)
        let provider = BundleAppSourceProvider(bundleProvider: bundleProvider)
        self.viewer = DocumentationViewer(provider: provider, globalThemeSettings: .docsee)
        self.navigator = navigator
    }

    @Environment(\.supportsMultipleWindows)
    private var supportsMultipleWindows
    
    var body: some View {
        DocumentationView(viewer: viewer)
            .toolbar {
                ToolbarItem(id: "navigation", placement: .navigation) {
                    NavigationButtons(viewer: viewer)
                }
            }
            .onChange(of: navigator.selection, initial: true) { _, newValue in
                guard let newValue else { return }
                viewer.navigate(to: .init(bundleIdentifier: newValue.bundleIdentifier, path: newValue.path))
            }
            .task {
                do {
                    let urlDidChangePublisher = viewer.bridge.channel(for: .didNavigate)

                    let urlDidChangeNotifications = await urlDidChangePublisher.values(as: URL.self)

                    for try await url in urlDidChangeNotifications {
                        let topic = TopicReference(url: url)
                        navigator.selection = topic
                    }
                } catch {
                    print("failed to receive url changes: \(error)")
                }
            }
    }
}

struct NavigationButtons: View {
    let viewer: DocumentationViewer

    var body: some View {
        ControlGroup {
            Button(action: { viewer.goBack() }) {
                Image(systemName: "chevron.backward")
            }
            .disabled(!viewer.canGoBack)

            Button(action: { viewer.goForward() }) {
                Image(systemName: "chevron.forward")
            }
            .disabled(!viewer.canGoForward)
        }
        .controlGroupStyle(.navigation)
    }
}
