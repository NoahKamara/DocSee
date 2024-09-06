////
////  File.swift
////
////
////  Created by Noah Kamara on 04.09.24.
////
//
// import SwiftUI
//
////struct TestView3<Content: View>: View {
//    @ViewBuilder
//    var content: Content
//
//    var body: some View {
//        HStack {
//            VStack {
//                ForEach(sections: content) { section in
//                    VStack(alignment: .leading) {
//                        HStack {
//                            section.header
//                        }
//                        .foregroundStyle(.red)
//
//                        VStack(alignment: .leading) {
//
//                            ForEach(sections: section.content) { section2 in
//                                HStack {
//                                    section2.header.first ?? Text("S")
//                                }
//                                .foregroundStyle(.green)
//
//                                section2.content
//                                    .foregroundStyle(.blue)
//                            }
//                        }
//                        .padding(.leading, 10)
//                    }
//                }
//            }
//        }
//    }
// }
//
// #Preview {
//    TestView3 {
//        Section("1") {
//            Section("1.1") {
//                Text("1.1.1")
//                Text("1.1.2")
//            }
//
//            Text("1.2")
//        }
//        Section("2") {
//            Text("2.1")
//            Text("2.2")
//        }
//    }
// }
