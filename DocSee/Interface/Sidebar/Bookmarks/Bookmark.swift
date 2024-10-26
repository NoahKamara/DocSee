//
//  Bookmark.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import CoreTransferable
import Docsy
import Foundation
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

import SwiftUI

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

    @Environment(\.supportsMultipleWindows)
    private var supportsMultipleWindows

    var body: some View {
        LeafView(node: .groupMarker("Bookmarks"), canEdit: false)

        if isDropping {
            Text("DROPPING")
        }
        if !bookmarks.isEmpty {
            ForEach(bookmarks, id: \.topic) { bookmark in
                Label {
                    Text(bookmark.displayName)
                } icon: {
                    Image(systemName: "bookmark")
                        .padding(2)
                }
                .contextMenu {
                    if supportsMultipleWindows {
                        OpenTopicInWindowButton(bookmark.topic)
                    }
                    CopyTopicToClipboardButton(bookmark.topic)
                }
            }
            .onInsert(of: [.bookmark]) { offset, items in
                dropItems(items, at: offset)
            }
            .animation(.default, value: bookmarks)
        } else {
            ForEach([0], id: \.self) { _ in
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
