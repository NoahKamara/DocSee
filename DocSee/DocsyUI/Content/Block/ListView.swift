import Docsy
import SwiftUI

/// A base view View for ordered and unordered lists
struct ListView<Marker: View>: View {
    typealias Item = BlockContent.ListItem

    let items: [Item]

    @ViewBuilder
    var marker: (_ item: Item, _ index: Int) -> Marker

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(0..<items.count, id: \.self) { index in
                let item = items[index]
                Label {
                    BlockContentsView(item.content)
                } icon: {
                    marker(item, index)
                }
            }
            .padding(.leading, 10)
        }
    }
}

#Preview("Lists") {
    PreviewDocument("//documentation/testdocumentation/list")
}

struct OrderedListView: View {
    let list: BlockContent.OrderedList
    var body: some View {
        ListView(items: list.items) { _, index in
            Text("\(Int(list.startIndex) + index).")
        }
    }
}

struct UnorderedListView: View {
    let list: BlockContent.UnorderedList
    var body: some View {
        ListView(items: list.items) { item, _ in
            Group {
                if let isChecked = item.checked {
                    // items checked property is set indicating a todo list
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                } else {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .font(.caption)
                }
            }
        }
    }
}

struct TermListView: View {
    let list: BlockContent.TermList
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(list.items, id: \.term.inlineContent.plainText) { item in
                VStack(alignment: .leading, spacing: 3) {
                    InlineContentView(item.term.inlineContent)
                    BlockContentsView(item.definition.content)
                        .padding(.leading, 10)
                }
            }
        }
    }
}
