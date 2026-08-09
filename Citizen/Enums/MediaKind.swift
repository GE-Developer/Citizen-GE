//
//  MediaKind.swift
//  Citizen
//
//  Created by GE-Developer
//

enum MediaKind: CaseIterable {
    case alphabetImage
    case alphabetLetterAudio
    case alphabetExampleAudio
    case questionAudio
    case questionImage
    
    var folder: String {
        switch self {
        case .alphabetImage:
            return "Alphabet/Example Images"
        case .alphabetLetterAudio:
            return "Alphabet/Letter Audio"
        case .alphabetExampleAudio:
            return "Alphabet/Example Audio"
        case .questionAudio, .questionImage:
            return "Questions"
        }
    }
    
    var versionRow: String {
        switch self {
        case .alphabetImage,
                .alphabetLetterAudio,
                .alphabetExampleAudio,
                .questionAudio,
                .questionImage:
            return "media"
        }
    }
}
