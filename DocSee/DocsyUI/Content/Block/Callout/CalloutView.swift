import SwiftUI

struct CalloutView<Content: View>: View {
    let tint: Color

    @ViewBuilder
    var content: Content

    init(
        _ tint: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            content
        }
        .safeAreaPadding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(in: ContainerRelativeShape())
        .padding(1)
        .overlay(tint.secondary, in: ContainerRelativeShape().stroke(lineWidth: 2))
        .padding(1)
        .containerShape(RoundedRectangle(cornerRadius: 15))
        .backgroundStyle(tint.quinary)

    }
}

#Preview {
    CalloutView(.red) {
        Text("This is Red")
    }
    .padding()
}

