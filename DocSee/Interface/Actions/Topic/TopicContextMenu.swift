//
//  TopicContextMenu.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI

struct TopicContextMenu: View {
    @Environment(\.supportsMultipleWindows)
    private var supportsMultipleWindows

    let topic: TopicReference

    init(_ topic: TopicReference) {
        self.topic = topic
    }

    var body: some View {
        if supportsMultipleWindows {
            OpenTopicInWindowButton(topic)
        }
        CopyTopicToClipboardButton(topic)
    }
}
