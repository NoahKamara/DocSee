//
//  NavigatorTreeView.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI

struct NavigatorTreeView: View {
    let tree: NavigatorTree

    var body: some View {
//        NavigatorTreeRootView(root: tree.root)
        ForEach(tree.root.children) { child in
            NodeView(node: child, canEdit: true)
        }
        .onMove { indices, newOffset in
            print("MOVE")
            withAnimation(.default) {
                tree.root.moveChildren(from: indices, to: newOffset)
            }
        }
    }
}

#Preview {
    List {
        NavigatorTreeView(tree: .preview())
    }
}

// MARK: Root

private struct NavigatorTreeRootView: View {
    let root: NavigatorTree.Node

    var body: some View {
        ForEach(root.children) { child in
            NodeView(node: child, canEdit: true)
        }
        .onMove { indices, newOffset in
            withAnimation(.default) {
                root.moveChildren(from: indices, to: newOffset)
            }
        }
    }
}

// MARK: Node

struct BundleRootView: View {
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
            if langNode.children.count > 1 {
                DisclosureGroup(isExpanded: $isExpanded) {
                    OutlineGroup(langNode.children, children: \.nonEmptyChildren) { child in
                        LeafView(node: child, canEdit: false)
                    }
                } label: {
                    HStack(spacing: 2) {
                        LeafView(
                            node: .init(
                                title: bundle.title,
                                reference: nil,
                                type: .root
                            ),
                            canEdit: false
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            isExpanded = true

                            if let topic = langNode.children.first?.reference {
                                navigator.goto(topic)
                            }
                        }

                        Menu {
                            ForEach(bundle.children, id: \.id) { langNode in
                                Button(action: {
                                    currentLanguage = langNode
                                }) {
                                    Label {
                                        Text(langNode.title)
                                    } icon: {
                                        if currentLanguage?.id == langNode.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(langNode.title)
                        }
                        .menuStyle(ButtonMenuStyle())
                        .buttonStyle(.borderedProminent)
                    }
                }
            } else if let first = langNode.children.first {
                DisclosureGroup {
                    OutlineGroup(first.children, children: \.nonEmptyChildren) { child in
                        LeafView(node: child, canEdit: false)
                    }
                } label: {
                    LeafView(node: first, canEdit: false)
                }
            }
        } else {
            ProgressView()
                .onChange(of: bundle.children.isEmpty) { _, _ in
                    currentLanguage = bundle.children.first
                }
                .environment(\.controlSize, .mini)
        }
    }
}

// #Preview {
//    BundleRootView()
// }

private struct NodeView: View {
    let node: NavigatorTree.Node

    @State
    var isExpanded: Bool = false

    var canEdit: Bool = false

    var body: some View {
        if node.type == .root {
//            LanguageGroupNodeView(node: node)
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
        }
    }
}

struct TappableDisclosureGroup: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        Section {
            if configuration.isExpanded {
                configuration.content
            }
        } header: {
            HStack {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: { configuration.isExpanded.toggle() }) {
                    Image(systemName: "chevron.right")
                        .rotationEffect(configuration.isExpanded ? .degrees(90) : .zero)
                }
            }
        }
    }
}

extension NavigatorTree.Node {
    var nonEmptyChildren: [NavigatorTree.Node]? {
        access(keyPath: \.children)
        return children.isEmpty ? nil : children
    }
}

// MARK: LanguageGroup

private struct LanguageGroupNodeView: View {
    var node: NavigatorTree.Node

    var language: SourceLanguage = .swift

    init(node: NavigatorTree.Node) {
        self.node = node
    }

    var body: some View {
        ForEach(node.children.first!.children) { subNode in
            OutlineGroup(subNode, children: \.nonEmptyChildren) { child in
                LeafView(node: child, canEdit: false)
                    .tag(child.reference)
            }
            .moveDisabled(true)
        }
//        if node.children.isEmpty {
//            LeafView(node: child, canEdit: false)
//        } else {
//            DisclosureGroup {
//                ForEach(node.children) { child in
//                    NodeView(node: child, isExpanded: false)
//                }
//            } label: {
//                LeafView(node: child, canEdit: false)
//            }
//        }
//
//        DisclosureGroup(node.children, children: \.nonEmptyChildren) { child in
//
//        }
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
    var navigator: Navigator?

    var body: some View {
        Group {
            if let topic = node.reference {
                Label {
                    Text(node.title)
                } icon: {
                    PageTypeIcon(node.type)
                }
                .contextMenu {
                    TopicContextMenu(topic)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    navigator?.selection = topic
                }
                .draggable(Bookmark(topic: topic, displayName: node.title))
                .tag(topic)
                .contextMenu {
                    TopicContextMenu(topic)
                }
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

private struct GroupMarkerView: View {
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
