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

private struct NodeView: View {
    let node: NavigatorTree.Node

    @State
    var isExpanded: Bool = false

    var canEdit: Bool = false

    var body: some View {
        if node.type == .languageGroup {
            LanguageGroupNodeView(node: node)
        } else if !node.children.isEmpty {
            DisclosureGroup {
                ForEach(node.children) { child in
                    NodeView(node: child)
                        .moveDisabled(true)
                }
            } label: {
                LeafView(node: node, canEdit: false)
            }
        } else {
            LeafView(node: node, canEdit: canEdit)
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
        OutlineGroup(node.children, children: \.nonEmptyChildren) { child in
            LeafView(node: child, canEdit: false)
        }
    }
}

// MARK: Leaf



struct LeafView: View {
    @Bindable
    var node: NavigatorTree.Node

    let canEdit: Bool
    
    @Environment(\.supportsMultipleWindows)
    private var supportsMultipleWindows

    var body: some View {
        Group {
            if let topic = node.reference {
                if node.type == .root {
                    Label {
                        Text(node.title)
                    } icon: {
                        PageTypeIcon(.framework)
                    }
                    .contextMenu {
                        if supportsMultipleWindows {
                            OpenTopicInWindowButton(topic)
                        }
                        CopyTopicToClipboardButton(topic)
                    }
                } else {
                    Label {
                        Text(node.title)
                    } icon: {
                        PageTypeIcon(node.type)
                    }
                    .tag(topic)
                    .onDrag({
                        print("DRAGGING")
                        return NSItemProvider()
                    })
                    .draggable(Bookmark(topic: topic, displayName: node.title))
                    .contextMenu {
                        if supportsMultipleWindows {
                            OpenTopicInWindowButton(topic)
                        }
                        CopyTopicToClipboardButton(topic)
                    }
                }
            } else if case .groupMarker = node.type {
                GroupMarkerView(node: node, canEdit: canEdit)
            } else {
                Label(node.title, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                    .onAppear {
                        print("Unknown Node type", node.type)
                    }
            }
        }
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
