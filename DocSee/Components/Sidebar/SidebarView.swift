
import Docsy
import SwiftUI

struct SidebarView: View {
    @Environment(DocumentationContext.self)
    private var context

    @State
    var language: SourceLanguage = .swift

    @Bindable
    var navigator: Navigator


    var body: some View {
        List(selection: $navigator.selection) {
            NavigatorTreeView(tree: context.index.tree, language: language)

            if context.index.tree.isEmpty {
                Text("No Content yet")
            }
        }
        .safeAreaInset(edge: .top) {
            LanguagePicker(context.index.tree.availableLanguages, selection: $language)
                .padding(.horizontal, 10)
        }
    }
}

#Preview(traits: .workspace) {
    SidebarView(navigator: .init())
        .listStyle(.sidebar)
        .frame(maxHeight: .infinity)
}
