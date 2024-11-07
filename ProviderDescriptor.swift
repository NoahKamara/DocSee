////
////  ProviderDescriptor.swift
////  DocSee
////
////  Copyright © 2024 Noah Kamara.
////
//
//import Foundation
//
//public enum ProviderID: String, Hashable, CaseIterable {
//    case filesystem
////    case http
//
//    var tint: Color {
//        switch self {
//        case .filesystem: .yellow
//        }
//    }
//
//    var icon: String {
//        switch self {
//        case .filesystem: "folder"
//        }
//    }
//
//    var displayName: String {
//        switch self {
//        case .filesystem: "Filesystem"
//        }
//    }
//}
//
//import SwiftUI
//
//// struct ProviderLabel: View {
////    let kind: ProviderID
////
////    var body: some View {
////        Label(kind.displayName, systemImage: kind.icon)
////            .background(descriptor.kind.tint.gradient.secondary)
////    }
//// }
//
//struct ProviderTileView: View {
//    let title: String
//    let overview: String
//    let kind: ProviderID
//
//    init(title: String, overview: String, kind: ProviderID) {
//        self.title = title
//        self.overview = overview
//        self.kind = kind
//    }
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .fontWeight(.medium)
//                .foregroundStyle(.secondary)
//
//            Text(overview)
//                .lineLimit(3, reservesSpace: true)
//        }
//        .padding(10)
//        .background(kind.tint.gradient.tertiary)
//        .containerShape(RoundedRectangle(cornerRadius: 10))
//    }
//}
//
//struct ProviderRowView: View {
//    let title: String
//    let overview: String
//    let kind: ProviderID
//
//    init(title: String, overview: String, kind: ProviderID) {
//        self.title = title
//        self.overview = overview
//        self.kind = kind
//    }
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .fontWeight(.medium)
//                .foregroundStyle(.secondary)
//
//            Text(overview)
//                .lineLimit(3, reservesSpace: true)
//        }
//        .padding(10)
//        .background(kind.tint.gradient.tertiary)
//        .containerShape(RoundedRectangle(cornerRadius: 10))
//    }
//}
//
//// struct ProviderManagerView: View {
////
////    var body: some View {
////        ScrollView {
////            ForEach(ProviderID.allCases) { id in
////            ProviderRowView
////                title: kind.kind,
////                overview: kind.overview,
////                kind: kind
////                )
////            }
////        }
////    }
//// }
////
//// #Preview {
////    ProviderManagerView()
////        .frame(width: 300)
//// }
