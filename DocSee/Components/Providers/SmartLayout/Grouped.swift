//
//  Grouped.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

// import SwiftUI
//
// extension EnvironmentValues {
//    @Entry var groupLevel: Int = 0
//    @Entry var groupStyle: GroupStyle = .automatic
// }
//
//
// struct Grouped: View {
//    let section: SectionConfiguration
//
//    init(section: SectionConfiguration) {
//        self.section = section
//    }
//
//    @Environment(\.groupLevel)
//    var groupLevel
//
//    @Environment(\.groupStyle)
//    var groupStyle
//
//    var body: some View {
//        Group {
//            let groupStyle = section.containerValues.providerSectionStyle.replaceUnspecified(with: .list)
//
//            if groupLevel == 0 {
//                VStack {
//                    HStack {
//                        Text("0")
//                        section.header
//                    }
//                    .font(.headline)
//
//
//                    Group {
//                        switch groupStyle {
//                        case .list, .automatic:
//                            VStack(spacing: 15) {
//                                ForEach(sections: section.content) { subsection in
//                                    Grouped(section: subsection)
//                                }
//                            }
//
//                        case .grid:
//                            GroupLayout(style: groupStyle) {
//                                section.content
//                            }
//                        }
//                    }
//                    .safeAreaPadding(10)
//                    .background(.background.secondary, in: RoundedRectangle(cornerRadius: 23))
//                }
//
//            } else if groupLevel == 1 {
//                Text(groupLevel.description)
//                Group {
//                    switch groupStyle {
//                    case .list, .automatic:
//                        VStack(spacing: 15) {
//                            Text("LIST")
//
//                            Group(sections: section.content) { subviews in
//                                ForEach(subviews) { subsection in
////                                    subviews
//                                    let groupStyle = subsection.containerValues.providerSectionStyle.replaceUnspecified(with: .list)
////                                    Grouped(section: subsection)
//                                }
//                            }
//
////                            ForEach(subviews: section.content) { subsection in
////                                let subsectionStyle = subsection.containerValues.providerSectionStyle.replaceUnspecified(with: .list)
////
////                                GroupLayout(style: subsectionStyle) {
//////                                    subsection
////                                    Text("SUB")
////                                }
////                            }
//
//                        }
//
//                    case .grid:
//                        Text("GRID")
////                        GroupLayout(style: groupStyle) {
////                            section.content
////                        }
//                    }
//                }
////                Group {
////                    switch groupStyle {
////                    case .list, .automatic:
////                        Text("LIST")
////                        GroupLayout(style: .list) {
////                            section.content
////                        }
////
////                    case .grid:
////                        Text("GRID")
////                        GroupLayout(style: groupStyle) {
////                            section.content
////                        }
////                    }
////                }
//            } else {
//                VStack {
//                    Text("LEVEL = \(groupLevel)")
//                    GroupLayout(style: groupStyle) {
//                        section.content
//                    }
//                }
//            }
//        }
//        .environment(\.groupLevel, groupLevel + 1)
//        .border(.green)
//    }
// }
//
// extension EnvironmentValues {
//    @Entry var providerSectionTint: Color? = nil
// }
//
//
//
//
//// MARK: Style
// enum GroupStyle {
//    case automatic
//    case grid
//    case list
//
//    func replaceUnspecified(with style: GroupStyle) -> Self {
//        if case .automatic = self {
//            style
//        } else {
//            self
//        }
//    }
//
//    func resolve(elements: Int) -> GroupStyle {
//        guard case .automatic = self else {
//            return self
//        }
//
//        if elements <= 3 {
//            return .list
//        } else {
//            return .grid
//        }
//    }
// }
//
//
