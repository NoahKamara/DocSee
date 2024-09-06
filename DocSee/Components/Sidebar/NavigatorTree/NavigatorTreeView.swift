//
//  NavigatorTreeView.swift
// DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI

struct NavigatorTreeView: View {
    var tree: NavigatorIndex.NavigatorTree

    var language: SourceLanguage

    var body: some View {
        Group {
            ForEach(tree.children ?? []) { child in
                NodeView(node: child)
            }
        }
        .environment(\.sourceLanguage, language)
    }
}

extension EnvironmentValues {
    @Entry
    var sourceLanguage: SourceLanguage = .swift
}

// MARK: Node

private extension NavigatorTreeView {
    struct NodeView: View {
        @Bindable
        var node: NavigatorIndex.Node

        @Environment(\.sourceLanguage)
        var sourceLanguage

        var body: some View {
            switch node.type {
            case .languageGroup:
                if let languageNode = node as? NavigatorIndex.LanguageGroup {
                    LanguageNodeView(node: languageNode)
                } else {
                    Text("Invalid")
                }

            case .root:
                ForEach(node.children ?? []) { child in
                    NodeView(node: child)
                }

            default:
                if let children = node.children {
                    DisclosureGroup {
                        ForEach(children) { child in
                            NodeView(node: child)
                        }
                    } label: {
                        LeafView(node: node)
                    }
                } else {
                    LeafView(node: node)
                }
            }
        }
    }
}

// MARK: LanguageNodeView

private extension NavigatorTreeView {
    struct LanguageNodeView: View {
        let node: NavigatorIndex.LanguageGroup

        @Environment(\.sourceLanguage)
        var sourceLanguage

        var body: some View {
            if let children = node.children {
                ForEach(children) { languageChild in
                    NodeView(node: languageChild)
                }
            }
        }
    }
}
