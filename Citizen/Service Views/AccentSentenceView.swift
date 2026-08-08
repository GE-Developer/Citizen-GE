//
//  AccentSentenceView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AccentSentenceView: View {
    private let segments: [RichTextSegment]
    private let lineLimit: Int?
    
    init(segments: [RichTextSegment], lineLimit: Int? = nil) {
        self.segments = segments
        self.lineLimit = lineLimit
    }
    
    var body: some View {
        accentSentence
    }
}

// MARK: - Builder
extension AccentSentenceView {
    private var accentSentence: some View {
        HStack(spacing: 10) {
            Capsule()
                .frame(width: 2)
                .foregroundStyle(Gradient.accent)
            RichTextView(segments: segments, lineLimit: lineLimit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }
}
