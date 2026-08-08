//
//  RichTextSegment.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

enum RichTextSegment: Hashable {
    case word(AttributedString)
    case blank
    case lineBreak
}
