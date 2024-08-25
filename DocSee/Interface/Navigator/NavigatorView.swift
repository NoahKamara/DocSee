
import SwiftUI
import Docsy

struct NavigatorView: View {
    @Environment(DocumentationContext.self)
    private var context

    @State
    var language: SourceLanguage = .swift

    @Bindable
    var navigator: Navigator

    var body: some View {
        List(selection: $navigator.selection) {
            Section {
                ForEach(context.bundleIdentifiers, id:\.self) { identifier in
                    NavigatorIndexView(identifier: identifier, context: context)
                }
            }
        }
    }
}
