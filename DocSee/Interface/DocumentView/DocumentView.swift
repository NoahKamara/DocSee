//
//  DocumentView.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import BundleAppSourceProvider
import DocCViewer
import Docsy
import SwiftUI
import UniformTypeIdentifiers

extension ThemeSettings {
    static let docsee: ThemeSettings = {
        var settings = ThemeSettings()
//        settings.features.docs.i18n.enable()
        settings.features.docs.quickNavigation.enable()

        settings.theme.aside.borderStyle = "solid"
        settings.theme.aside.borderRadius = "15px"
        settings.theme.aside.borderWidth = "2px 2px 2px 2px"

        settings.typography.htmlFont = "\"SF Pro Display\",system-ui,-apple-system,BlinkMacSystemFont"
        var color = settings.theme.color

//        color.fill = .pair(light: "#FFFFFF", dark: "#1e1e1e")
//        color.fillSecondary = .pair(light: "#fbfbfd", dark: "#161617")
//        color.fillTertiary = .pair(light: "#f5f5f7", dark: "")
//        color.fillQuaternary = .pair(light: "#252525", dark: "")

        color["fill"] = .pair(light: "#fff", dark: "#1e1e1e")
        color["fill-blue"] = .pair(light: #"None"#, dark: "#0071e3")
        color["fill-blue-secondary"] = .pair(light: "#f6fbff", dark: "#001931")
        color["fill-gray"] = .pair(light: "#1d1d1f", dark: "#f5f5f7")
        color["fill-gray-quaternary"] = .pair(light: "#e8e8ed", dark: "#333336")
        color["fill-gray-secondary"] = .pair(light: "#86868b", dark: "#6e6e73")
        color["fill-gray-tertiary"] = .pair(light: "#d2d2d7", dark: "#424245")
        color["fill-green-secondary"] = .pair(light: "#f5fff6", dark: "#002b03")
        color["fill-light-blue-secondary"] = .pair(light: "#eaf3ff", dark: "#002a51")
        color["fill-light-gray-secondary"] = .pair(light: "#f5f5f7", dark: "#323232")
        color["fill-orange-secondary"] = .pair(light: "#fff9f4", dark: "#290d00")
        color["fill-purple-secondary"] = .pair(light: "#fcf8ff", dark: "#190325")
        color["fill-quaternary"] = .single("#252525")
        color["fill-red-secondary"] = .pair(light: "#fff2f4", dark: "#300")
        color["fill-secondary"] = .pair(light: "#fbfbfd", dark: "#161617")
        color["fill-teal-secondary"] = .pair(light: "#faffff", dark: "#002d2b")
        color["fill-tertiary"] = .pair(light: "#f5f5f7", dark: "#1d1d1f")
        color["fill-yellow-secondary"] = .pair(light: "#fffbf2", dark: "#2b1e00")

        color["article-body-background"] = .pair(light: #"None"#, dark: #"var(--color-fill-secondary)"#)
        color["aside-deprecated"] = .single(#"var(--color-figure-orange)"#)
        color["aside-deprecated-background"] = .single(#"var(--color-fill-orange-secondary)"#)
        color["aside-deprecated-border"] = .single(#"var(--color-figure-orange)"#)
        color["aside-experiment"] = .single(#"var(--color-figure-purple)"#)
        color["aside-experiment-background"] = .single(#"var(--color-fill-purple-secondary)"#)
        color["aside-experiment-border"] = .single(#"var(--color-figure-purple)"#)
        color["aside-important"] = .single(#"var(--color-figure-yellow)"#)
        color["aside-important-background"] = .single(#"var(--color-fill-yellow-secondary)"#)
        color["aside-important-border"] = .single(#"var(--color-figure-yellow)"#)
        color["aside-note"] = .single(#"var(--color-figure-light-gray)"#)
        color["aside-note-background"] = .single(#"var(--color-fill-light-gray-secondary)"#)
        color["aside-note-border"] = .single(#"var(--color-figure-light-gray)"#)
        color["aside-tip"] = .single(#"var(--color-figure-teal)"#)
        color["aside-tip-background"] = .single(#"var(--color-fill-teal-secondary)"#)
        color["aside-tip-border"] = .single(#"var(--color-figure-teal)"#)
        color["aside-warning"] = .single(#"var(--color-figure-red)"#)
        color["aside-warning-background"] = .single(#"var(--color-fill-red-secondary)"#)
        color["aside-warning-border"] = .single(#"var(--color-figure-red)"#)
        color["badge-beta"] = .single(#"var(--color-figure-teal)"#)
        color["badge-dark-beta"] = .single("#7dffe4")
        color["badge-dark-spi"] = .single("#f14bf1")
        color["badge-spi"] = .single(#"var(--color-figure-pink)"#)
        color["button-background-active"] = .single(#"var(--color-fill-blue)"#)
        color["button-background-hover"] = .single("#0077ed")
        color["card-accent"] = .single(#"var(--color-figure-blue)"#)
        color["changes-added"] = .single(#"var(--color-figure-green)"#)
        color["changes-added-hover"] = .single(#"var(--color-fill-green-secondary)"#)
        color["changes-deprecated"] = .single(#"var(--color-figure-orange)"#)
        color["changes-deprecated-hover"] = .pair(light: #"rgba(191, 72, 0, 0.05)"#, dark: #"rgba(245, 99, 0, 0.05)"#)
        color["changes-modified"] = .single(#"var(--color-figure-purple)"#)
        color["changes-modified-hover"] = .single(#"var(--color-fill-purple-secondary)"#)
        color["changes-modified-previous-background"] = .single(#"var(--color-fill)"#)
        color["code-background"] = .pair(light: #"var(--color-fill-tertiary)"#, dark: #"var(--color-fill-gray-quaternary)"#)
        color["code-collapsible-background"] = .pair(light: #"var(--color-fill-gray-quaternary)"#, dark: #"var(--color-fill-tertiary)"#)
        color["code-line-highlight"] = .pair(light: #"var(--color-fill-light-blue-secondary)"#, dark: #"var(--color-fill-gray-tertiary)"#)
        color["code-line-highlight-border"] = .single(#"var(--color-figure-light-blue)"#)
        color["code-plain"] = .pair(light: "#000", dark: "#fff")
        color["dropdown-border"] = .single(#"var(--color-fill-gray-tertiary)"#)
        color["eyebrow"] = .single(#"inherit"#)
        color["figure-blue"] = .pair(light: "#06c", dark: "#2997ff")
        color["figure-gray"] = .pair(light: "#1d1d1f", dark: "#f5f5f7")
        color["figure-gray-secondary"] = .pair(light: "#6e6e73", dark: "#86868b")
        color["figure-gray-secondary-alt"] = .pair(light: "#515154", dark: "#a1a1a6")
        color["figure-gray-tertiary"] = .pair(light: "#86868b", dark: "#6e6e73")
        color["figure-green"] = .pair(light: "#008009", dark: "#03a10e")
        color["figure-light-blue"] = .pair(light: "#4ca9ff", dark: "#7dc1ff")
        color["figure-light-gray"] = .pair(light: "#696969", dark: "#9a9a9e")
        color["figure-orange"] = .pair(light: "#bf4800", dark: "#f56300")
        color["figure-pink"] = .pair(light: "#b0b", dark: "#f14bf1")
        color["figure-purple"] = .pair(light: "#8c28c2", dark: "#a95ed2")
        color["figure-red"] = .pair(light: "#e30000", dark: "#ff3037")
        color["figure-teal"] = .pair(light: "#3d777d", dark: "#7dffe4")
        color["figure-yellow"] = .pair(light: "#9e6700", dark: "#ffb50f")

        color["grid"] = .single(#"var(--color-fill-gray-tertiary)"#)
        color["hero-eyebrow"] = .single(#"inherit"#)
        color["highlight-green"] = .pair(light: "#e4fee6", dark: "#032603")
        color["highlight-red"] = .pair(light: "#f8dddd", dark: "#410606")
        color["nav-dark-outlines"] = .single("#424245")
        color["nav-dark-solid-background"] = .single("#2d2d2d")
        color["nav-outlines"] = .single(#"var(--color-fill-gray-tertiary)"#)
        color["navigator-item-hover"] = .pair(light: #"rgba(0, 113, 227, 0.2)"#, dark: #"rgba(0, 113, 227, 0.6)"#)
        color["not-found-input-background"] = .pair(light: #"var(--color-fill-secondary)"#, dark: #"var(--color-fill-gray-quaternary)"#)
        color["not-found-input-border"] = .single(#"var(--color-fill-gray-tertiary)"#)
        color["standard-blue"] = .pair(light: #"var(--color-type-icon-sky)"#, dark: #"var(--color-type-icon-sky)"#)
        color["standard-gray"] = .pair(light: "#afafaf", dark: "#afafaf")
        color["standard-green"] = .pair(light: #"var(--color-type-icon-teal)"#, dark: #"var(--color-type-icon-teal)"#)
        color["standard-orange"] = .pair(light: "#ff5a00", dark: "#ff5a00")
        color["standard-purple"] = .pair(light: #"var(--color-type-icon-purple)"#, dark: #"var(--color-type-icon-purple)"#)
        color["standard-red"] = .pair(light: #"var(--color-type-icon-pink)"#, dark: #"var(--color-type-icon-pink)"#)
        color["standard-yellow"] = .pair(light: "#ff9f2c", dark: "#ff9f2c")
        color["step-background"] = .pair(light: #"None"#, dark: #"var(--color-fill-gray-quaternary)"#)
        color["step-caption"] = .single(#"var(--color-fill-gray-tertiary)"#)
        color["step-focused"] = .single(#"var(--color-figure-light-blue)"#)
        color["step-text"] = .single(#"var(--color-figure-gray)"#)
        color["svg-icon"] = .pair(light: "#86868b", dark: "#6e6e73")
        color["tabnav-item-border-color"] = .single(#"var(--color-fill-gray-tertiary)"#)
        color["tutorial-navbar-dropdown-background"] = .pair(light: #"None"#, dark: #"var(--color-nav-dark-solid-background)"#)
        color["tutorial-navbar-dropdown-border"] = .pair(light: #"var(--color-dropdown-border)"#, dark: #"var(--color-fill-gray-tertiary)"#)
        color["tutorials-overview-background"] = .single(#"radial-gradient(circle at center 70%,#242424 0%,#0c0c0c 100%)"#)
        color["tutorials-overview-content"] = .single("#f5f5f7")
        color["tutorials-overview-content-alt"] = .single("#a1a1a6")
        color["tutorials-overview-eyebrow"] = .single("#a1a1a6")
        color["tutorials-overview-icon"] = .single("#a1a1a6")
        color["tutorials-overview-navigation-link-active"] = .single("#f5f5f7")
        color["tutorials-overview-navigation-link-hover"] = .single("#a1a1a6")
        color["tutorials-teal"] = .pair(light: "#38a39c", dark: "#54c4bc")
        color["type-icon-blue"] = .single("#272ad8")
        color["type-icon-green"] = .single("#090")
        color["type-icon-orange"] = .single("#947100")
        color["type-icon-pink"] = .single("#d82797")
        color["type-icon-purple"] = .single("#bf6af7")
        color["type-icon-sky"] = .single("#06c")
        color["type-icon-teal"] = .single("#509ca3")

        settings.theme.color = color

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

    @Environment(\.openURL)
    private var openURL

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
            .task(id: "url-did-change") {
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
            .task(id: "open-url") {
                do {
                    let events = await viewer.bridge.channel(for: .openURL).values(as: URL.self)

                    for try await url in events {
                        openURL(url, completion: {
                            if !$0 {
                                print("failed to open url\(url)")
                            }
                        })
                    }
                } catch {
                    print("failed to receive openUrl", error)
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
