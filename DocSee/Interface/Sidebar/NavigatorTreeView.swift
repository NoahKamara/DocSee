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


struct BundleLeafView: View {
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
    
    var body: some View {
        HStack(spacing: 2) {
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
                        reference: language?.reference ?? language?.children.first?.reference,
                        type: pageType(language)
                    ),
                    canEdit: false
                )
            })
            .onTapGesture {
                if let language {
                    if let topic = language.children.first?.reference {
                        navigator.goto(topic)
                    }
                    withAnimation {
                        isExpanded = true
                    }
                } else {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        }
        .contextMenu {
            if let language, bundle.children.count > 1 {
                Menu {
                    ForEach(bundle.children, id: \.id) { langNode in
                        Button(action: {
                            self.language = langNode
                        }) {
                            Label {
                                Text(langNode.title)
                            } icon: {
                                if self.language?.id == langNode.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Text("Language: "+(language.title))
                }
                .menuStyle(ButtonMenuStyle())
                .buttonStyle(.borderedProminent)
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
            // Has language
            DisclosureGroup(isExpanded: $isExpanded) {
                if langNode.children.count > 1 {
                    OutlineGroup(langNode.children, children: \.nonEmptyChildren) { child in
                        LeafView(node: child, canEdit: false)
                    }
                } else if let first = langNode.children.first {
                    OutlineGroup(first.children, children: \.nonEmptyChildren) { child in
                        LeafView(node: child, canEdit: false)
                    }
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    navigator?.selection = topic
                }
                .draggable(Bookmark(topic: topic, displayName: node.title))
                .tag(topic)
                .contextMenu {
                    TopicActions.ContextMenu(topic)
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
