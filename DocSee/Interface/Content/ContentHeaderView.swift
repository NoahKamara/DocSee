//
//  ContentHeaderView.swift
//  DocSee
//
//  Created by Noah Kamara on 27.08.24.
//

import SwiftUI
import Docsy

struct ContentHeaderView: View {
    let document: Document
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(document.metadata.roleHeading ?? "")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(document.metadata.title ?? "")
                .font(.title)

            InlineContentView(content: document.abstract ?? [])
        }
    }
}

#Preview {
    let document = Previews.document
    ContentHeaderView(document: document)
}

extension [InlineContent] {
    func attributed() -> AttributedString {
        reduce(into: AttributedString()) { result, element in
            result += element.attributed()
        }
    }
}
extension InlineContent {
    func attributed() -> AttributedString {
        var string: AttributedString

        switch self {
        case .codeVoice(let code):
            string = AttributedString(code)
            string.font = .body.monospaced()

        case .emphasis(let inlineContent):
            string = inlineContent.attributed()
            string.font = (string.font ?? .body).italic()

        case .strong(let inlineContent):
            string = inlineContent.attributed()
            string.font = (string.font ?? .body).bold()

        case .strikethrough(let inlineContent):
            string = inlineContent.attributed()
            string.strikethroughStyle = .single
            string.strikethroughColor = .white

//        case .image(let identifier, let metadata):

//        case .reference(let identifier, let isActive, let overridingTitle, let overridingTitleInlineContent):
//
        case .text(let text):
            string = AttributedString(text)
//
//        case .newTerm(let inlineContent):
//
//        case .inlineHead(let inlineContent):
//
//        case .subscript(let inlineContent):
//
//        case .superscript(let inlineContent):
//

        default:
            print("NOT IMPLEMENTED")
            string = AttributedString(self.plainText)
            string.foregroundColor = .red
        }

        return string
    }
}


struct InlineContentView: View {
    let content: [InlineContent]

    var attributedString: AttributedString {
        content.attributed()
    }

    var body: some View {
        Text(attributedString)
    }
}



public extension Text {
    init(@TextBuilder builder: () -> Text) {
        self = builder()
    }
}

@resultBuilder
public struct TextBuilder {
    public static func buildBlock<Data, ID>(_ forEach: ForEach<Data, ID, Text>) -> Text? {
        //        forEach.data.reduce(Text(""), { forEach.content($0) })
        if let first = forEach.data.first {
            forEach.data
                .dropFirst()
                .map(forEach.content)
                .reduce(forEach.content(first), buildPartialBlock)
        } else {
            Text("")
        }
    }

    public static func buildPartialBlock(first: Text) -> Text {
        first
    }

    public static func buildPartialBlock(accumulated: Text, next: Text) -> Text {
        accumulated+next
    }

    public static func buildEither(first component: Text) -> Text {
        component
    }

    public static func buildEither(second component: Text) -> Text {
        component
    }

    public static func buildOptional(_ component: Text?) -> Text {
        component ?? Text("")
    }
}
