//
//  ProviderManagerView.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

// import SwiftUI
//
// enum ContainerStyle {
//    case grid
//    case list
// }
//
// extension ContainerValues {
//    @Entry var containerStyle = ContainerStyle.list
// }
//
// struct ContainerLayout<Content: View>: View {
//    @ViewBuilder
//    var content: Content
//
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//
//    var body: some View {
//        List {
//            ForEach(sections: content) { section in
//                Container(section: section)
//            }
//            .listRowSeparator(.hidden)
//        }
//    }
// }
//
// struct Container: View {
//    let section: SectionConfiguration
//
//    @Environment(\.groupLevel)
//    var level
//
//    var body: some View {
//        let style = section.containerValues.containerStyle
//
//        Group {
//            switch level {
//            case 0:
//                VStack {
//                    HStack {
//                        section.header
//                    }
//                    .font(.headline)
//
//                    VStack(spacing: 15) {
//                        ForEach(sections: section.content) { subsection in
//                            Container(section: section)
//                        }
//                    }
//                }
//                .background(.teal)
//
//            default:
//                VStack {
//                    let style = section.containerValues.containerStyle
//
//                    Text("Lvl 1")
//
//                    Group {
//                        switch style {
//                        case .list:
//                            VStack(spacing: 15) {
//                                Group(sections: section.content) { subviews in
//                                    ForEach(subviews) { subsection in
////                                        Container(section: subsection)
//                                        Text("Row")
//                                    }
//                                }
//                            }
//
//                        case .grid:
//                            Text("GRID")
//                        }
//                    }
//                    .safeAreaPadding(10)
//                }
//                .background(.green)
//
////            case 2:
////                VStack {
////                    HStack {
////                        Text("Lvl 1")
////                        section.header
////                    }
////                    .font(.headline)
////
////                    Group {
////                        switch style {
////                        case .list:
////                            VStack(spacing: 15) {
////                                Group(sections: section.content) { subviews in
////                                    ForEach(subviews) { subsection in
////                                        Container(section: subsection)
////                                    }
////                                }
////                            }
////
////                        case .grid:
////                            Text("GRID")
////                        }
////                    }
////                    .safeAreaPadding(10)
////                    .background(.background.secondary, in: RoundedRectangle(cornerRadius: 23))
////                }
////                .background(.orange)
////
////            default:
////                ForEach(section.content) { subview in
////                    subview
////                }
//            }
//        }
//        .environment(\.groupLevel, level + 1)
//    }
// }
//
// #Preview {
//    ContainerLayout {
//        Section("Section 1") {
//            Text("Content 1.1")
//
//            Section("Section 2") {
//                Text("Content 1.2.1")
//                Text("Content 1.2.2")
//            }
//
//            Text("Content 1.3")
//        }
//
////        Section("Section 2") {
////            Text("Content 2.1")
////            Text("Content 2.2")
////            Text("Content 2.3")
////            //            Section("Section 1.4") {
////            //                Text("Content 1.4.1")
////            //                Text("Content 1.4.2")
////            //            }
////            //            Text("Content 1.4")
////        }
//    }
// }
//
//
// struct ProviderManagerView: View {
//    @State
//    var providers: [ProviderConfiguration] = []
//
//    var body: some View {
//        GroupedCollection {
//            Section("Mixed") {
//                Section {
//                    Text("View the latest documentation from Apple")
//                        .groupItem("DocC 2", systemImage: "applelogo")
//
//                    Text("A search engine for packages supporting the Swift Package Manager")
//                        .groupItem("Swift Package Index", systemImage: "book.pages")
//
//
//                    Text("Out Cloud platform for building, versioning and sharing documentation.")
//                        .groupItem("Docsy Cloud", systemImage: "cloud")
//                }
//                .providerSectionStyle(.grid)
//
//                Section {
//                    Text("View the latest documentation from Apple")
//                        .groupItem("DocC 2", systemImage: "applelogo")
//
//                    Text("A search engine for packages supporting the Swift Package Manager")
//                        .groupItem("Swift Package Index", systemImage: "book.pages")
//
//
//                    Text("Out Cloud platform for building, versioning and sharing documentation.")
//                        .groupItem("Docsy Cloud", systemImage: "cloud")
//                }
//                .providerSectionStyle(.list)
//            }
//
//            Section("Grid Only") {
//                Text("View the latest documentation from Apple")
//                    .groupItem("DocC 2", systemImage: "applelogo")
//
//                Text("A search engine for packages supporting the Swift Package Manager")
//                    .groupItem("Swift Package Index", systemImage: "book.pages")
//
//
//                Text("Out Cloud platform for building, versioning and sharing documentation.")
//                    .groupItem("Docsy Cloud", systemImage: "cloud")
//            }
//            .providerSectionStyle(.grid)
//
//            Section("List Only") {
//                Text("View the latest documentation from Apple")
//                    .groupItem("DocC 2", systemImage: "applelogo")
//
//                Text("A search engine for packages supporting the Swift Package Manager")
//                    .groupItem("Swift Package Index", systemImage: "book.pages")
//
//
//                Text("Out Cloud platform for building, versioning and sharing documentation.")
//                    .groupItem("Docsy Cloud", systemImage: "cloud")
//            }
////            .providerSectionStyle(.list)
//
//            Section("List Only") {
//                Text("View the latest documentation from Apple")
//                    .groupItem("DocC 2", systemImage: "applelogo")
//
//                Text("A search engine for packages supporting the Swift Package Manager")
//                    .groupItem("Swift Package Index", systemImage: "book.pages")
//
//
//                Text("Out Cloud platform for building, versioning and sharing documentation.")
//                    .groupItem("Docsy Cloud", systemImage: "cloud")
//            }
//            .providerSectionStyle(.list)
//
//
//            Section("Online Documentation") {
//                Section {
//                    Text("View the latest documentation from Apple")
//                        .groupItem("Apple Documentation", systemImage: "applelogo")
//
//                    Text("A search engine for packages supporting the Swift Package Manager")
//                        .groupItem("Swift Package Index", systemImage: "book.pages")
//
//
//                    Text("Out Cloud platform for building, versioning and sharing documentation.")
//                        .groupItem("Docsy Cloud", systemImage: "cloud")
//                }
//                .providerSectionStyle(.grid)
//
//                Text("View the latest documentation from Apple")
//                    .groupItem("Apple Documentation", systemImage: "applelogo")
//
//                Text("A search engine for packages supporting the Swift Package Manager")
//                    .groupItem("Swift Package Index", systemImage: "book.pages")
//
//
//                Text("Out Cloud platform for building, versioning and sharing documentation.")
//                    .groupItem("Docsy Cloud", systemImage: "cloud")
//            }
//
//
//
////            Grouped("Online Documentations") {
////                Text("View the latest documentation from Apple")
////                    .groupItem("Apple Documentation", systemImage: "applelogo")
////
////                Text("A search engine for packages supporting the Swift Package Manager")
////                    .groupItem("Swift Package Index", systemImage: "book.pages")
////
////
////                Text("Out Cloud platform for building, versioning and sharing documentation.")
////                    .groupItem("Docsy Cloud", systemImage: "cloud")
////            }
////            .providerSectionStyle(.grid)
//
//            Section("Online") {
//                Text("Example A")
//                    .groupItem("Example A", systemImage: "book.pages")
//                Text("Example A")
//                    .groupItem("Example A", systemImage: "book.pages")
//
//                Section {
//                    Text("Example B")
//                        .groupItem("Example A", systemImage: "book.pages")
//
//                    Text("Example B")
//                        .groupItem("Example A", systemImage: "book.pages")
//                }
//            }
//        }
////        GroupedCollection {
////
////
//////            Section {
//////                Text("Example A")
//////                    .groupItem("Example A", systemImage: "book.pages")
//////                Text("Example A")
//////                    .groupItem("Example A", systemImage: "book.pages")
//////            }
//////
//////            Section("Hello") {
//////                Text("Example A")
//////                    .groupItem("Example A", systemImage: "book.pages")
//////                Text("Example A")
//////                    .groupItem("Example A", systemImage: "book.pages")
//////            }
//////            .providerSectionStyle(.list)
////
////
////
//////            Grouped("Online Documentation") {
//////                Text("Use the latest documentation from [developer.apple.com](https.//developer.apple.com)")
//////                    .groupItem("Apple Documentation", systemImage: "chevron.left.forwardslash.chevron.right")
//////
//////                Text("Import any bundle from the Swift Package Index")
//////                    .groupItem("Swift Package Index", systemImage: "chevron.left.forwardslash.chevron.right")
//////
//////                Text("DocSee Premium")
//////                    .groupItem("Swift Package Index", systemImage: "chevron.left.forwardslash.chevron.right")
//////
//////                Section {
//////                    Text("Use the latest documentation from [developer.apple.com](https.//developer.apple.com)")
//////                        .groupItem("Apple Documentation", systemImage: "chevron.left.forwardslash.chevron.right")
//////
//////                    Text("Use the latest documentation from [developer.apple.com](https.//developer.apple.com)")
//////                        .groupItem("Apple Documentation", systemImage: "chevron.left.forwardslash.chevron.right")
//////                }
//////                .providerSectionStyle(.grid)
//////            }
//////            .providerSectionStyle(.list)
//////            .providerTint(.teal)
////
//////            Section("Examples") {
//////                Text("An example documentation archive")
//////                    .groupItem("Example Catalog", systemImage: "book.pages")
//////            }
//////            .providerTint(.teal)
//////
//////            Section("File System") {
//////                Text("Access DocC Archives from your files")
//////                    .groupItem("File System", systemImage: "folder")
//////
//////                Text("Link any documentation archives in your iCloud files")
//////                    .groupItem("iCloud", systemImage: "icloud.fill")
//////            }
//////            .providerTint(.yellow)
//////            .providerSectionStyle(.list)
////        }
//    }
// }
//
// #Preview {
//    ProviderManagerView()
// }
