//
//  GroupLayout.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

// import SwiftUI
//
// struct GroupLayout<Content: View>: View {
//    let style: GroupStyle
//    @ViewBuilder
//    var content: Content
//
//    var body: some View {
//        Group {
//            switch style {
//            case .grid:
//                LazyVGrid(
//                    columns: [.init(.adaptive(minimum: 150, maximum: 300), spacing: 5, alignment: .top)],
//                    alignment: .center,
//                    spacing: 5
//                ) {
//                    ForEach(subviews: content) { tile in
//                        ProviderTile(
//                            title: tile.containerValues.providerTitle,
//                            icon: tile.containerValues.providerIcon,
//                            tint: .primary
//                        ) {
//                            tile
//                        }
//                    }
//                }
//
//            case .list:
//                LazyVStack(spacing: 5) {
//                    ForEach(subviews: content) { tile in
//                        ProviderRow(
//                            title: tile.containerValues.providerTitle,
//                            icon: tile.containerValues.providerIcon,
//                            tint: .primary
//                        ) {
//                            tile
//                                .foregroundStyle(.secondary)
//                        }
//                    }
//                }
//
//            default: EmptyView()
//            }
//        }
//    }
// }
//
// struct ContainerSubLayout<Content: View>: View {
//    let style: ContainerStyle
//    var content: Content
//
//    init(style: ContainerStyle, content: Content) {
//        self.style = style
//        self.content = content
//    }
//
//    var body: some View {
//        Group {
//            switch style {
//            case .grid:
//                LazyVGrid(
//                    columns: [.init(.adaptive(minimum: 150, maximum: 300), spacing: 5, alignment: .top)],
//                    alignment: .center,
//                    spacing: 5
//                ) {
//                    ForEach(subviews: content) { tile in
//                        ProviderTile(
//                            title: tile.containerValues.providerTitle,
//                            icon: tile.containerValues.providerIcon,
//                            tint: .primary
//                        ) {
//                            tile
//                        }
//                    }
//                }
//
//            case .list:
//                LazyVStack(spacing: 5) {
//                    ForEach(subviews: content) { tile in
//                        ProviderRow(
//                            title: tile.containerValues.providerTitle,
//                            icon: tile.containerValues.providerIcon,
//                            tint: .primary
//                        ) {
//                            tile
//                                .foregroundStyle(.secondary)
//                        }
//                    }
//                }
//            }
//        }
//    }
// }
//
//
//// MARK: Tile
// struct ProviderTile<Content: View>: View {
//    let title: Text
//    let icon: Image?
//    var tint: Color = .primary
//    @ViewBuilder
//    var content: Content
//
//    var body: some View {
//        CalloutView(tint) {
//            VStack(alignment: .center,spacing: 4) {
//                HStack(spacing: 5) {
//                    if let icon {
//                        icon
//                            .symbolVariant(.fill)
//                    }
//
//                    ProviderTitleView(title)
//                        .minimumScaleFactor(0.8)
//                        .lineLimit(1)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//
//                Divider()
//                    .ignoresSafeArea(.container, edges: .horizontal)
//
//                content
//                    .font(.callout)
//                    .lineLimit(3, reservesSpace: true)
//            }
//        }
//    }
// }
//
//// MARK: Row
// struct ProviderRow<Content: View>: View {
//    let title: Text
//    let icon: Image?
//    var tint: Color = .primary
//    @ViewBuilder
//    var content: Content
//
//    var body: some View {
//        CalloutView(tint) {
//            HStack(alignment: .firstTextBaseline) {
//                if let icon {
//                    icon
//                        .symbolVariant(.fill)
//                }
//
//                ProviderTitleView(title)
//                    .foregroundStyle(tint)
//                    .containerShape(RoundedRectangle(cornerRadius: 15))
//
//                content
//            }
//            .lineLimit(1, reservesSpace: true)
//        }
//    }
// }
//
//
// fileprivate struct ProviderTitleView: View {
//    let title: Text
//
//    init(_ title: Text) {
//        self.title = title
//    }
//
//    var body: some View {
//        title
//            .fontWeight(.medium)
//    }
// }
