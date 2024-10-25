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
    
    var body: some View {
        DisclosureGroup {
            if let langNode {
                if langNode.children.count > 1 {
                    OutlineGroup(langNode.children, children: \.nonEmptyChildren) { child in
                        LeafView(node: child, canEdit: false)
                    }
                } else if let first = langNode.children.first {
                    OutlineGroup(first.children, children: \.nonEmptyChildren) { child in
                        LeafView(node: child, canEdit: false)
                    }
                }
            } else {
                ProgressView()
            }
        } label: {
            LeafView(node: bundle, canEdit: false)
        }

    }
}

//#Preview {
//    BundleRootView()
//}

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
                Group {
                    if node.type == .root {
                        Label {
                            Text(node.title)
                        } icon: {
                            PageTypeIcon(.framework)
                        }
                        .contextMenu {
                            TopicContextMenu(topic)
                        }
                    } else {
                        Label {
                            Text(node.title)
                        } icon: {
                            PageTypeIcon(node.type)
                        }
                    }
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
                Label(node.title, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                    .onAppear {
                        print("Unknown Node type", node.type)
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
