//
//  ContentHeaderView.swift
//  DocSee
//
//  Created by Noah Kamara on 27.08.24.
//

import SwiftUI
import Docsy

struct ContentHeaderView: View {
    let roleHeading: String?
    let title: String?
    let abstract: [InlineContent]?

    var body: some View {
        VStack(alignment: .leading) {
            if let roleHeading {
                Text(roleHeading)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            Group {
                if let title {
                    Text(title)
                } else {
                    Text("Documentation")
                }
            }
            .font(.title)

            if let abstract {
                InlineContentView(content: abstract)
            }
        }
    }
}

#Preview {
    let document = Previews.document
    ContentHeaderView(
        roleHeading: "Article",
        title: "How to train a Dragon",
        abstract: [
            .text("Be a "),
            .emphasis(inlineContent: [.text("nice ")]),
            .strong(inlineContent: [.text("person")])
        ]
    )
}

