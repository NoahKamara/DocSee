//
//  NavigatorTreeView.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI

struct NavigatorTreeView: View {
    @Environment(DocSeeContext.self)
    var context: DocSeeContext?
    
    let tree: NavigatorTree

    var body: some View {
        ForEach(tree.root.children) { child in
            NodeView(node: child)
        }
        .onMove { indices, newOffset in
            withAnimation(.default) {
                tree.root.moveChildren(from: indices, to: newOffset)
            }
            
            Task { try await context?.save() }
        }
    }
}

#Preview {
    List {
        NavigatorTreeView(tree: .preview())
    }
}


// MARK: Node

struct NodeView: View {
    let node: NavigatorTree.Node

    @State
    var isExpanded: Bool = false

    var canEdit: Bool = false

    var body: some View {
        if node.type == .root {
            BundleRootView(bundle: node)
        } else if !node.children.isEmpty {
            DisclosureGroup {
                ForEach(node.children) { child in
                    NodeView(node: child)
                }
            } label: {
                LeafView(node: node, canEdit: false)
            }
        } else {
            LeafView(node: node, canEdit: canEdit)
                .moveDisabled(canEdit)
        }
    }
}

fileprivate extension NavigatorTree.Node {
    var nonEmptyChildren: [NavigatorTree.Node]? {
        access(keyPath: \.children)
        return children.isEmpty ? nil : children
    }
}


// MARK: Bundle Root
fileprivate struct BundleRootView: View {
    let bundle: NavigatorTree.Node

    var langNode: NavigatorTree.Node? {
        bundle.children
            .first(where: { $0.reference?.sourceLanguage == .swift }) ?? bundle.children.first
    }

    @State
    var isExpanded: Bool = false

    @Environment(Navigator.self)
    private var navigator

    @State
    var currentLanguage: NavigatorTree.Node?

    init(
        bundle: NavigatorTree.Node,
        isExpanded: Bool = false
    ) {
        self.bundle = bundle
        self.isExpanded = isExpanded
        self.currentLanguage = bundle.children.first
    }

    var body: some View {
        if let langNode = currentLanguage {
            // Has language
            DisclosureGroup(isExpanded: $isExpanded) {
                if langNode.children.count > 1 {
                    OutlineGroup(langNode.children, children: \.nonEmptyChildren) { child in
                        LeafView(node: child, canEdit: false)
                            .moveDisabled(true)
                    }
                } else if let first = langNode.children.first {
                    LeafView(
                        node: .init(
                            title: first.title,
                            reference: first.reference,
                            type: first.type
                        ),
                        canEdit: false
                    )
                    .moveDisabled(true)
                    
                    OutlineGroup(first.children, children: \.nonEmptyChildren) { child in
                        LeafView(node: child, canEdit: false)
                            .moveDisabled(true)
                    }
                    .moveDisabled(true)
                }
            } label: {
                BundleLeafView(
                    bundle: bundle,
                    language: $currentLanguage,
                    isExpanded: $isExpanded
                )
            }
        } else {
            BundleLeafView(
                bundle: bundle,
                language: $currentLanguage,
                isExpanded: $isExpanded
            )
            .safeAreaInset(edge: .trailing) {
                ProgressView()
                    .environment(\.controlSize, .mini)
            }
            .onChange(of: bundle.children.isEmpty) { _, _ in
                currentLanguage = bundle.children.first
            }
        }
    }
}

// MARK: Bundle Leaf
fileprivate struct BundleLeafView: View {
    let bundle: NavigatorTree.Node
    
    @Binding
    var language: NavigatorTree.Node?
    
    @Environment(Navigator.self)
    private var navigator
     
    @Binding
    var isExpanded: Bool
    
    private func pageType(_ language: NavigatorTree.Node?) -> PageType {
        if let language, language.children.count == 1 {
            language.children.first!.type
        } else {
            .framework
        }
    }
    
    var rootNode: NavigatorTree.Node {
        language
            .map({ node in
                node.children.first(where: { $0.type == .framework }) ?? node.children.first ?? bundle
            }) ?? bundle
    }
    
    var body: some View {
        LabeledContent(content: {
            if let language, bundle.children.count > 1 {
                Text(language.title)
                    .font(.caption)
                    .padding(2)
                    .background(in: .rect(cornerRadius: 5))
                    .backgroundStyle(Color.accentColor.tertiary)
            }
        }, label: {
            LeafView(
                node: .init(
                    title: bundle.title,
                    reference: language?.reference,
                    type: .root
                ),
                canEdit: false
            )
        })
    }
}


// MARK: Leaf

struct LeafView: View {
    @Bindable
    var node: NavigatorTree.Node

    let canEdit: Bool

    @Environment(\.supportsMultipleWindows)
    private var supportsMultipleWindows

    @Environment(Navigator.self)
    var navigator: Navigator

    var body: some View {
        Group {
            if let topic = node.reference {
                Label {
                    if node.children.isEmpty {
                        Text(node.title)
                    } else {
                        Text(node.title)
#if os(iOS) // Highlight selected items on ios
                            .bold(navigator.selection == topic)
                            .foregroundStyle(navigator.selection == topic ? .primary : .primary)
#endif
                    }
                } icon: {
                    PageTypeIcon(node.type)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .tag(topic)
                .contextMenu {
                    TopicActions.ContextMenu(topic)
                }
#if os(iOS)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    navigator.goto(topic)
                }
#endif
                
            } else if case .groupMarker = node.type {
                GroupMarkerView(node: node, canEdit: canEdit)
            } else {
                Label {
                    Text(node.title)
                } icon: {
                    PageTypeIcon(node.type)
                }
            }
        }
        .lineLimit(1)
    }
}

fileprivate struct GroupMarkerView: View {
    @Bindable
    var node: NavigatorTree.Node

    let canEdit: Bool

    @State
    var isEditing: Bool = false

    @FocusState
    var isFocused: Bool

    func editTitle() {
        isEditing = true
        isFocused = true
    }

    var body: some View {
        Group {
            if canEdit {
                if isEditing {
                    TextField("New Group", text: $node.title)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .onChange(of: isFocused) { _, newValue in
                            if !newValue {
                                isEditing = false
                            }
                        }
                        .onSubmit {
                            isFocused = false
                        }
                } else {
                    Text(node.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contextMenu {
                            Button(action: { editTitle() }) {
                                Label("Rename", systemImage: "pencil")
                            }
                        }
                }
            } else {
                Text(node.title)
            }
        }
        .fontWeight(.semibold)
        .foregroundStyle(.secondary)
    }
}

// #Preview {
//    GroupMarkerView()
// }
