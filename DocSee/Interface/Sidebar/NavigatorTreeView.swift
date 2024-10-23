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

extension TopicReference: @retroactive Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .topic)
    }
}

import UniformTypeIdentifiers

extension UTType {
    static var topic = UTType(exportedAs: "com.docsee.topic", conformingTo: .json)
    static var bookmark = UTType(exportedAs: "com.docsee.bookmark", conformingTo: .json)
}

struct Bookmark: Codable, Transferable, Equatable {
    let topic: TopicReference
    let displayName: String
    
    init(
        topic: TopicReference,
        displayName: String
    ) {
        self.topic = topic
        self.displayName = displayName
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .bookmark)
    }
}

struct BookmarksView: View {
    @State
    var bookmarks: [Bookmark] = []
    
    func dropItems(_ items: [NSItemProvider], at offset: Int = 0) {
        print("DROP", offset)
        
        for item in items {
            _ = item.loadTransferable(type: Bookmark.self) { result in
                switch result {
                case .success(let ref):
                    Task { @MainActor in
                        bookmarks.insert(ref, at: offset)
                    }
                case .failure(let err):
                    print("err", err)
                }
            }
        }
    }
    
    @State
    var isDropping: Bool = false
    
    var body: some View {
        LeafView(node: .groupMarker("Bookmarks"), canEdit: false)
        
        if !bookmarks.isEmpty {
            ForEach(bookmarks, id:\.topic) { bookmark in
                Label {
                    Text(bookmark.displayName)
                } icon: {
                    Image(systemName: "bookmark")
                        .padding(2)
                }
                .contextMenu {
                    OpenTopicInWindowButton(bookmark.topic)
                    CopyTopicToClipboardButton(bookmark.topic)
                }
            }
            .onInsert(of: [.bookmark]) { offset, items in
                dropItems(items, at: offset)
            }
            .animation(.default, value: bookmarks)
        } else {
            Group {
                Text("Add Bookmarks by dragging topics here")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .onDrop(of: [.bookmark], isTargeted: $isDropping) { items in
                dropItems(items, at: 0)
                return true
            }
        }
    }
}

#Preview {
    List {
        BookmarksView()
        Divider()
        NavigatorTreeView(tree: .preview())
    }
    .listStyle(.sidebar)
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
                        OpenTopicInWindowButton(topic)
                        CopyTopicToClipboardButton(topic)
                    }
                } else {
                    Label {
                        Text(node.title)
                    } icon: {
                        PageTypeIcon(node.type)
                    }
                    .tag(topic)
                    .draggable(Bookmark(topic: topic, displayName: node.title))
                    .contextMenu {
                        OpenTopicInWindowButton(topic)
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
