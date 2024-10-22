//
//  LanguagePicker.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import DocsySchema
import SwiftUI

extension SidebarView {
    struct LanguagePicker: View {
        @Binding
        var selection: SourceLanguage
        let languages: Set<SourceLanguage>

        init(_ languages: Set<SourceLanguage>, selection: Binding<SourceLanguage>) {
            self._selection = selection
            self.languages = languages
        }

        private var choices: [SourceLanguage] {
            let known = SourceLanguage.knownLanguages.filter(languages.contains(_:))

            return known + Array(languages.subtracting(.init(known)))
        }

        var body: some View {
            Picker("", selection: $selection) {
                ForEach(choices, id: \.self) { choice in
                    Text(choice.name)
                }
            }
            .labelsHidden()
        }
    }
}

#Preview {
    @Previewable @State var selection = SourceLanguage.swift

    SidebarView.LanguagePicker([.swift, .objective], selection: $selection)
}
