import Docsy
import SwiftUI

struct NavigatorTreeView: View {
    var tree: NavigatorIndex.NavigatorTree

    var language: SourceLanguage

    var body: some View {
        NodeView(node: tree.root)
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
        let node: NavigatorIndex.Node

        @Environment(\.sourceLanguage)
        var sourceLanguage

        var body: some View {
            switch node.type {
            case .languageGroup:
                if
                    let languageGroup = (node as? NavigatorIndex.LanguageGroup),
                    let children = languageGroup.children,
                    languageGroup.language == sourceLanguage
                {
                    ForEach(children) { languageChild in
                        NodeView(node: languageChild)
                    }
                }

            case .root:
                if let children = node.children {
                    ForEach(children) { child in
                        NodeView(node: child)
                    }
                }

            default:
                if let children = node.children {
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
                } else {
                    LeafView(node: node)
                }
            }
        }
    }
}
