import SwiftUI
import DocsySchema

extension BlockContent.AsideStyle.OutputStyle {
    var color: Color {
        switch self {
        case .experiment: .purple
        case .important: .orange
        case .note: .gray
        case .tip: .teal
        case .warning: .red
        }
    }
}

struct AsideView: View {
    let aside: BlockContent.Aside

    init(_ aside: BlockContent.Aside) {
        self.aside = aside
    }

    var body: some View {
        CalloutView(aside.style.renderKind.color) {
            Text(aside.displayName)
                .font(.headline)
                .foregroundStyle(aside.style.renderKind.color)

            VStack(alignment: .leading) {
                BlockContentsView(aside.content)
            }
        }
    }
}


#Preview {
    let content: [BlockContent] = [.paragraph(.init(inlineContent: [.text("This is an Aside")]))]

    let asides: [BlockContent.Aside] = [
        .init(style: .known(.tip), content: content),
        .init(style: .known(.experiment), content: content),
        .init(style: .known(.important), content: content),
        .init(style: .known(.warning), content: content),
        .init(style: .known(.note), content: content),
        .init(displayName: "Custom Name", style: .known(.warning), content: content),
        .init(style: .unknown("Custom Style"), content: content),
    ]

    ScrollView {
        LazyVStack(spacing: 10) {
            ForEach(Array(zip(0..<asides.count, asides)), id:\.0) { e in
                AsideView(e.1)
            }
        }
        .frame(maxWidth: .infinity)
    }
    .contentMargins(20)
}
