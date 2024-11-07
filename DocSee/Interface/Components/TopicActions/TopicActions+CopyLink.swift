//
//  CopyTopicToClipboardButton.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI

extension TopicActions {
    struct CopyLink: View {
        let topic: TopicReference
        
        init(_ topic: TopicReference) {
            self.topic = topic
        }
        
        var body: some View {
            Button(action: {
                Pasteboard.setURL(topic.url)
            }) {
                Label("Copy Link", systemImage: "document.on.clipboard")
            }
        }
    }
}

extension TopicReference {
    static let preview = TopicReference(
        bundleIdentifier: "com.noahkamara.DocSee",
        path: "/documentation/docsee",
        sourceLanguage: .swift
    )
}

#Preview {
    TopicActions.CopyLink(.preview)
        .padding(20)
}

enum Pasteboard {
    static let pasteboard: OSPasteboard = .general

#if os(macOS)
    typealias OSPasteboard = NSPasteboard

    static func setString(_ value: String) {
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
    }

    static func setURL(_ value: URL) {
        pasteboard.clearContents()
        pasteboard.setString(value.absoluteString, forType: .string)
    }

#else
    typealias OSPasteboard = UIPasteboard

    static func setString(_ value: String) {
        pasteboard.setObjects([value])
    }

    static func setURL(_ value: URL) {
        pasteboard.setObjects([value])
    }
#endif
}
