//
//  OpenTopicInNewWindow.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import AppIntents
import Docsy
import SwiftUI

extension TopicActions {
    struct OpenWindow: View {
        let topic: TopicReference
        
        public init(_ topic: TopicReference) {
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
}

#Preview {
    TopicActions.OpenWindow(.preview)
        .padding(20)
}
