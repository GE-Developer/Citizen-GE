//
//  Font + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreText
import Foundation
import SwiftUI

extension Font {
    static let citizen = CitizenFont()
}

struct CitizenFont {
    private let bicubikName = "Bicubik"
    
    func bicubik(_ size: CGFloat) -> Font {
        .custom(bicubikName, fixedSize: size)
    }
    
    func bicubikMetrics(
        of string: String,
        size: CGFloat,
        kerning: CGFloat
    ) -> (box: CGFloat, trailingGap: CGFloat, bottomGap: CGFloat) {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(rawValue: kCTFontAttributeName as String):
                CTFontCreateWithName(bicubikName as CFString, size, nil),
            NSAttributedString.Key(rawValue: kCTKernAttributeName as String): kerning
        ]
        
        let line = CTLineCreateWithAttributedString(
            NSAttributedString(string: string, attributes: attributes)
        )
        
        var descent: CGFloat = 0
        
        let box = CGFloat(CTLineGetTypographicBounds(line, nil, &descent, nil))
        let ink = CTLineGetImageBounds(line, nil)
        
        return (box, box - ink.maxX, descent + ink.minY)
    }
}
