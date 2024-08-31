import SwiftUI
import DocsySchema

struct ContentSectionsView: View {
    let sections: [AnyContentSection]

    init(_ sections: [AnyContentSection]) {
        self.sections = sections
    }

    var body: some View {
        ForEach(Array(sections.enumerated()), id:\.offset) { item in
            ContentSectionView(section: item.element)
        }
    }
}



