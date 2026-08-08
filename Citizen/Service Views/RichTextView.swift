//
//  RichTextView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct RichTextView: View {
    private let segments: [RichTextSegment]
    private let highlightsDictionaryWords: Bool
    private let lineLimit: Int?
    private let onTapWord: ((String) -> Void)?
    private let blankPlaceholder = "______"
    
    init(
        segments: [RichTextSegment],
        highlightsDictionaryWords: Bool = false,
        lineLimit: Int? = nil,
        onTapWord: ((String) -> Void)? = nil
    ) {
        self.segments = segments
        self.highlightsDictionaryWords = highlightsDictionaryWords
        self.lineLimit = lineLimit
        self.onTapWord = onTapWord
    }
    
    var body: some View {
        flowContent
    }
}

// MARK: - Builder
extension RichTextView {
    private var flowContent: some View {
        FlowLayout(lineSpacing: 4, lineLimit: lineLimit) {
            ForEach(Array(displaySegments.enumerated()), id: \.offset) { _, segment in
                segmentView(segment)
            }
        }
    }
    
    @ViewBuilder
    private func segmentView(_ segment: RichTextSegment) -> some View {
        switch segment {
        case .word(let attr):
            wordView(attr)
        case .blank:
            blankCapsule
        case .lineBreak:
            Color.clear
                .frame(width: 0, height: 0)
                .lineBreakMark()
        }
    }
    
    @ViewBuilder
    private func wordView(_ attr: AttributedString) -> some View {
        if let token = matchedWord(attr) {
            let word = Text(attr.underlined(word: token))
            if let onTapWord {
                word
                    .contentShape(Rectangle())
                    .onTapGesture { onTapWord(token) }
            } else {
                word
            }
        } else {
            Text(attr)
        }
    }
    
    private var blankCapsule: some View {
        Text(blankPlaceholder)
            .hidden()
            .overlay {
                Capsule()
                    .fill(Gradient.accent.opacity(0.18))
                    .stroke(Gradient.accent, lineWidth: 1)
                    .padding(.vertical, 2)
            }
    }
}

// MARK: - Logic
extension RichTextView {
    private var displaySegments: [RichTextSegment] {
        highlightsDictionaryWords ? segments.mergingDictionaryPhrases() : segments
    }
    
    private func matchedWord(_ attr: AttributedString) -> String? {
        guard highlightsDictionaryWords else { return nil }
        let token = attr.plainToken
        return WordsDictionary.shared.contains(token) ? token : nil
    }
}
