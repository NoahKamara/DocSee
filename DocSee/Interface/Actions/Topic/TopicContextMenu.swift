//
//  File.swift
//  DocSee
//
//  Created by Noah Kamara on 25.10.24.
//

import SwiftUI
import Docsy

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
