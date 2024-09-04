
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
        List {
            Button("Log") {
                print(context.index.tree.dumpTree())
            }
            NavigatorTreeView(tree: context.index.tree, language: language)
            if context.index.tree.root.children?.isEmpty != true {
                Text("No Content yet")
            }
        }
        .safeAreaInset(edge: .top) {
            LanguagePicker(context.index.root.availableLanguages, selection: $language)
                .padding(.horizontal, 10)
        }
    }
}

#Preview(traits: .workspace) {
    SidebarView(navigator: .init())
        .listStyle(.sidebar)
        .frame(maxHeight: .infinity)
}

import OSLog
