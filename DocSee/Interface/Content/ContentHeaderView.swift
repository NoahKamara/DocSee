//
//  ContentHeaderView.swift
//  DocSee
//
//  Created by Noah Kamara on 27.08.24.
//

import Docsy
import SwiftUI

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
    PreviewDocument(keyPath: \.metadata, \.abstract) { metadata, abstract in
        ContentHeaderView(
            roleHeading: metadata.roleHeading,
            title: metadata.title,
            abstract: abstract
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
