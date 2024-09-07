//
//  OptionalTopicButton.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI

struct OptionalTopicButton<Content: View>: View {
    let topic: TopicReference?
    let content: (TopicReference) -> Content

    init(
        _ topic: TopicReference?,
        @ViewBuilder content: @escaping (TopicReference) -> Content
    ) {
        self.topic = topic
        self.content = content
    }

    var body: some View {
        if let topic {
            content(topic)
        } else {
            content(.init(bundleIdentifier: "", path: "", sourceLanguage: .c))
                .disabled(true)
        }
    }
}

#Preview {
    OptionalTopicButton(.preview) {
        Button($0.path, action: {})
    }
}
