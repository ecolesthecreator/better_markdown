import SwiftUI

/// Renders a markdown table
struct TableView: View {
    let table: Table
    let style: MarkdownStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(table.headers.enumerated()), id: \.offset) { index, cell in
                    TableCellView(
                        cell: cell,
                        alignment: alignment(for: index),
                        isHeader: false,
                        style: style
                    )
                    .frame(maxWidth: .infinity)

                    if index < table.headers.count - 1 {
                        Divider()
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            Divider()

            // Body rows
            ForEach(Array(table.rows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { colIndex, cell in
                        TableCellView(
                            cell: cell,
                            alignment: alignment(for: colIndex),
                            isHeader: false,
                            style: style
                        )
                        .frame(maxWidth: .infinity)

                        if colIndex < row.count - 1 {
                            Divider()
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(rowIndex % 2 == 0 ? style.tableRowBackgroundColor : style.tableAlternateRowBackgroundColor)

                if rowIndex < table.rows.count - 1 {
                    Divider()
                }
            }
        }
        .overlay(
            Rectangle()
                .stroke(style.tableBorderColor, lineWidth: 1)
        )
        .padding(.bottom, style.paragraphSpacing)
    }

    private func alignment(for columnIndex: Int) -> HorizontalAlignment {
        guard columnIndex < table.columnAlignments.count else {
            return .leading
        }

        switch table.columnAlignments[columnIndex] {
        case .left, .none:
            return .leading
        case .center:
            return .center
        case .right:
            return .trailing
        }
    }
}

/// Renders a single table cell
struct TableCellView: View {
    let cell: TableCell
    let alignment: HorizontalAlignment
    let isHeader: Bool
    let style: MarkdownStyle

    var body: some View {
        VStack(alignment: alignment, spacing: 0) {
            InlineTextView(elements: cell.content, style: style)
                .font(style.bodyFont)
                .padding(style.tableCellPadding)
        }
        .frame(maxWidth: .infinity, alignment: swiftUIAlignment)
    }

    private var swiftUIAlignment: Alignment {
        switch alignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        default:
            return .leading
        }
    }
}
