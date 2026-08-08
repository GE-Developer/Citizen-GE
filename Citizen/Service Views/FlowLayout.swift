//
//  FlowLayout.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct FlowLayout: Layout {
    var lineSpacing: CGFloat = 4
    var emptyLineHeight: CGFloat = 16
    var lineLimit: Int? = nil
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        var line = 0
        
        for sub in subviews {
            if isLimitReached(line) { break }
            if sub[IsLineBreakKey.self] {
                let advance = lineHeight > 0 ? lineHeight : emptyLineHeight
                y += advance + lineSpacing
                x = 0
                lineHeight = 0
                line += 1
                continue
            }
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                y += lineHeight + lineSpacing
                x = 0
                lineHeight = 0
                line += 1
                if isLimitReached(line) { break }
            }
            x += size.width
            lineHeight = max(lineHeight, size.height)
            totalWidth = max(totalWidth, x)
        }
        return CGSize(width: totalWidth, height: y + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var line = 0
        
        for sub in subviews {
            if isLimitReached(line) {
                sub.place(at: bounds.origin, anchor: .topLeading, proposal: .zero)
                continue
            }
            if sub[IsLineBreakKey.self] {
                let advance = lineHeight > 0 ? lineHeight : emptyLineHeight
                y += advance + lineSpacing
                x = 0
                lineHeight = 0
                line += 1
                continue
            }
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                y += lineHeight + lineSpacing
                x = 0
                lineHeight = 0
                line += 1
                if isLimitReached(line) {
                    sub.place(at: bounds.origin, anchor: .topLeading, proposal: .zero)
                    continue
                }
            }
            sub.place(
                at: CGPoint(x: bounds.minX + x, y: bounds.minY + y),
                anchor: .topLeading,
                proposal: ProposedViewSize(size)
            )
            x += size.width
            lineHeight = max(lineHeight, size.height)
        }
    }
    
    private func isLimitReached(_ line: Int) -> Bool {
        guard let lineLimit else { return false }
        return line >= lineLimit
    }
}

// MARK: - IsLineBreakKey
private struct IsLineBreakKey: LayoutValueKey {
    static let defaultValue: Bool = false
}

// MARK: - View Extension
extension View {
    func lineBreakMark() -> some View {
        layoutValue(key: IsLineBreakKey.self, value: true)
    }
}
