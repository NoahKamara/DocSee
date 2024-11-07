//
//  TopicContextMenu.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI

extension TopicActions {
    struct ContextMenu: View {
        @Environment(\.supportsMultipleWindows)
        private var supportsMultipleWindows
        
        let topic: TopicReference
        
        init(_ topic: TopicReference) {
            self.topic = topic
        }
        
        var body: some View {
            if supportsMultipleWindows {
                OpenWindow(topic)
            }
            CopyLink(topic)
        }
    }
}
