//
//  String + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

// MARK: - String
extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    var asMarkdown: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        return (try? AttributedString(markdown: self, options: options)) ?? AttributedString(self)
    }
    
    var asRichSegments: [RichTextSegment] {
        var segments: [RichTextSegment] = []
        let blankToken = "<blank/>"
        let parts = components(separatedBy: blankToken)
        
        for (index, chunk) in parts.enumerated() {
            let attributed = chunk.parseUnderlineAwareMarkdown()
            segments.append(contentsOf: attributed.tokenizedIntoWords())
            if index < parts.count - 1 {
                segments.append(.blank)
            }
        }
        return segments
    }
    
    fileprivate func parseUnderlineAwareMarkdown() -> AttributedString {
        let lines = components(separatedBy: "\n")
        var result = AttributedString()
        
        for (index, line) in lines.enumerated() {
            result.append(line.parseUnderlineInline())
            if index < lines.count - 1 {
                result.append(AttributedString("\n"))
            }
        }
        return result
    }
    
    fileprivate func parseUnderlineInline() -> AttributedString {
        var result = AttributedString()
        var cursor = startIndex
        let openTag = "<u>"
        let closeTag = "</u>"
        
        while cursor < endIndex {
            guard let openRange = range(of: openTag, range: cursor..<endIndex),
                  let closeRange = range(of: closeTag, range: openRange.upperBound..<endIndex) else {
                result.append(String(self[cursor..<endIndex]).asMarkdown)
                break
            }
            
            let plain = String(self[cursor..<openRange.lowerBound])
            if !plain.isEmpty {
                result.append(plain.asMarkdown)
            }
            
            let inner = String(self[openRange.upperBound..<closeRange.lowerBound])
            var underlined = inner.asMarkdown
            underlined.underlineStyle = .single
            result.append(underlined)
            
            cursor = closeRange.upperBound
        }
        return result
    }
}

// MARK: - AttributedString
extension AttributedString {
    var plainToken: String {
        String(characters)
            .trimmingCharacters(in: CharacterSet.letters.inverted)
    }
    
    func underlined(word: String, color: Color = .citizen.secondaryText) -> AttributedString {
        var copy = self
        let style = Text.LineStyle(pattern: .solid, color: color)
        
        if let range = copy.range(of: word) {
            copy[range].underlineStyle = style
        } else {
            copy.underlineStyle = style
        }
        return copy
    }
    
    fileprivate func tokenizedIntoWords() -> [RichTextSegment] {
        var segments: [RichTextSegment] = []
        let chars = characters
        var wordStart = chars.startIndex
        var index = chars.startIndex
        
        while index < chars.endIndex {
            let character = chars[index]
            
            if character == "\n" {
                if index > wordStart {
                    segments.append(.word(AttributedString(self[wordStart..<index])))
                }
                segments.append(.lineBreak)
                index = chars.index(after: index)
                wordStart = index
                continue
            }
            
            if character.isWhitespace {
                let wordEnd = chars.index(after: index)
                segments.append(.word(AttributedString(self[wordStart..<wordEnd])))
                wordStart = wordEnd
                index = wordEnd
                continue
            }
            
            index = chars.index(after: index)
        }
        
        if wordStart < chars.endIndex {
            segments.append(.word(AttributedString(self[wordStart..<chars.endIndex])))
        }
        return segments
    }
}
