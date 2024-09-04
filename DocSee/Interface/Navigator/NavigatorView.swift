
import Docsy
import SwiftUI

struct NavigatorView: View {
    @Environment(DocumentationContext.self)
    private var context

    @State
    var language: SourceLanguage = .swift

    @Bindable
    var navigator: Navigator



    var body: some View {
        List {
            NavigatorTreeView(tree: context.index.tree, language: language)
        }
        .safeAreaInset(edge: .top) {
            LanguagePicker(context.index.root.availableLanguages, selection: $language)

        }
    }
}

#Preview(traits: .workspace) {
    NavigatorView(navigator: .init())
        .listStyle(.sidebar)
        .frame(maxHeight: .infinity)
}

import OSLog

