//
//  PageTypeIcon.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import SwiftUI

struct PageTypeIcon: View {
    enum Icon {
        case abbr(String, Color)
        case symbol(String)
        case unknown(PageType)
    }

    let icon: Icon

    init(_ type: PageType) {
        self.init(type.icon)
    }

    init(_ icon: Icon) {
        self.icon = icon
    }

    @Environment(\.isFocused)
    var isFocused

    var body: some View {
        Group {
            switch icon {
            case .abbr(let abbreviation, let color):
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundStyle(color.secondary)

                    Text(abbreviation)
                        .foregroundStyle(isFocused ? color : .white)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(2)

            case .symbol(let systemImage):
                Image(systemName: systemImage)
                    .padding(2)

            case .unknown(let type):
                Text("UNKNOWN \(type.rawValue)")
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    PageTypeIcon(.article)
}

private extension PageType {
    var icon: PageTypeIcon.Icon {
        switch self {
        case .root: .abbr("RT", .red)
        case .article: .symbol("text.document")
        case .overview: .symbol("app.connected.to.app.below.fill")
        case .tutorial: .symbol("square.fill.text.grid.1x2")
        //        case .section:
        //        case .learn:
        //        case .overview: .abbr("OV", .red)
        //        case .resources:
        //        case .symbol:
        case .framework: .symbol("square.stack.3d.up.fill")
        case .class: .abbr("C", .purple)
        case .structure: .abbr("S", .purple)
        case .protocol: .abbr("Pr", .purple)
        case .enumeration: .abbr("E", .purple)
        case .function, .instanceMethod, .initializer: .abbr("M", .purple)
        case .extension: .abbr("Ex", .orange)
        //        case .variable:
        //        case .typeAlias:
        //        case .associatedType:
        //        case .operator:
        //        case .macro:
        //        case .union:
        //        case .enumerationCase:
        case .instanceProperty: .abbr("P", .purple)
        //        case .subscript:
        //        case .typeMethod:
        //        case .typeProperty:
        //        case .buildSetting:
        //        case .propertyListKey:
        case .sampleCode: .symbol("curlybraces")
        //        case .httpRequest:
        //        case .dictionarySymbol:
        //        case .namespace:
        //        case .propertyListKeyReference:
        //        case .languageGroup:
        //        case .container:
        //        case .groupMarker:
        default: .unknown(self)
        }
    }
}
