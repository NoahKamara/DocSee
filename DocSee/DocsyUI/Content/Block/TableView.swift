// import SwiftUI
// import DocsySchema
//
//
// struct TableView: View {
//    let table: BlockContent.Table
//
//    init(_ table: BlockContent.Table) {
//        self.table = table
//    }
//
//    var body: some View {
//        TableLayout(
//            alignments: table.alignments,
//            extendedData: table.extendedData,
//            metadata: table.metadata
//        ) {
//            ForEach(Array(table.rows.enumerated()), id:\.offset) { rowItem in
//                ForEach(Array(rowItem.element.cells.enumerated()), id:\.offset) { cellItem in
//                    Text("CELL")
//                        .layoutValue(key: CellBounds.self, value: .init(
//                            origin: ,
//                            size: extendedData.
//                        ))
//                }
////                ForEach(row.cells) { <#Identifiable#> in
////                    <#code#>
////                }
//            }
//        }
//    }
// }
//
// #Preview {
//    PreviewDocument("//documentation/testdocumentation/table")
// }
//
// struct CellBounds: LayoutValueKey {
//    static var defaultValue: CGRect { .zero }
// }
//
// struct TableLayout: Layout {
//    //    var rows: [TableRow] = []
//
//    var alignments: [BlockContent.ColumnAlignment]? = nil
//    var extendedData: Set<BlockContent.TableCellExtendedData> = .init()
//    var metadata: ContentMetadata? = nil
//
//    struct Cache {
//        let layout: [CellCoordinate]
//    }
//
//    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
//        subviews
////        subviews
//    }
// }
