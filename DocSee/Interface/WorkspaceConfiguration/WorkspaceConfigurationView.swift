//
//  WorkspaceConfigurationView.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

////
////  WorkspaceConfigurationView.swift
////  DocSee
////
////  Created by Noah Kamara on 23.10.24.
////
//
// import SwiftUI
// import Docsy
//
//
// struct ProviderDescriptor: Codable {
//    enum Kind: Codable {
//        case localFS
//    }
//
//    let id: UUID
//    var kind: Kind {
//        switch config {
//        case .localFS: .localFS
//        }
//    }
//
//    let config: Config
//
//    enum Config: Codable {
//        case localFS(LocalFSConfig)
//    }
//
//    struct LocalFSConfig: Codable {
//        let rootPath: String
//    }
// }
//
//
// class Workspace: Codable {
//    let providers: [ProviderDescriptor]
//    let bundles: [UUID: DocumentationBundle.Metadata]
//    let index: NavigatorTree.Node
//
//    init(
//        bundles: [BundleIdentifier: DocumentationBundle.Metadata],
//        providers: [BundleIdentifier: ProviderDescriptor],
//        index: [NavigatorTree.Node]
//    ) {
//        self.sources = sources
//        self.index = index
//    }
// }
//
// struct WorkspaceDetailView: View {
//    let workspace: Workspace = .init(sources: [], index: )
//
//    var body: some View {
//        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
//    }
// }
//
// #Preview {
//    WorkspaceDetailView()
// }
