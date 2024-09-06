//
//  SidebarView.swift
// DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI

struct OpenTopicInWindowButton: View {
    let topic: TopicReference

    init(_ topic: TopicReference) {
        self.topic = topic
    }

    @Environment(\.openWindow)
    var openWindow

    var body: some View {
        Button(action: { openWindow(value: topic) }) {
            Label("Open in New Window", systemImage: "macwindow.badge.plus")
        }
    }
}

struct SidebarView: View {
    @Environment(DocumentationContext.self)
    private var context

    @State
    var language: SourceLanguage = .swift

    @Bindable
    var navigator: Navigator

    var body: some View {
        List(selection: $navigator.selection) {
            NavigatorTreeView(tree: context.index.tree, language: language)

            if context.index.tree.isEmpty {
                Text("No Content yet")
            }
        }
        .safeAreaInset(edge: .top) {
            LanguagePicker(context.index.tree.availableLanguages, selection: $language)
                .padding(.horizontal, 10)
        }
    }
}

#Preview(traits: .workspace) {
    SidebarView(navigator: .init())
        .listStyle(.sidebar)
        .frame(maxHeight: .infinity)
}
