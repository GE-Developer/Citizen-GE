//
//  LetterType.swift
//  Citizen
//
//  Created by GE-Developer
//

enum LetterType: CaseIterable {
    case georgian
    
    var characters: [Character] {
        switch self {
        case .georgian:
            return [
                "ა", "ბ", "გ", "დ", "ე", "ვ", "ზ", "თ", "ი", "კ",
                "ლ", "მ", "ნ", "ო", "პ", "ჟ", "რ", "ს", "ტ", "უ",
                "ფ", "ქ", "ღ", "ყ", "შ", "ჩ", "ც", "ძ", "წ", "ჭ",
                "ხ", "ჯ", "ჰ"
            ]
        }
    }
}
