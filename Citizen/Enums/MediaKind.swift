//
//  MediaKind.swift
//  Citizen
//
//  Created by GE-Developer
//

enum MediaKind {
    case alphabetImage
    case alphabetLetterAudio
    case alphabetExampleAudio
    case questionAudio
    
    var folder: String {
        switch self {
        case .alphabetImage:
            return "Alphabet/Example Images"
        case .alphabetLetterAudio:
            return "Alphabet/Letter Audio"
        case .alphabetExampleAudio:
            return "Alphabet/Example Audio"
        case .questionAudio:
            return "Questions"
        }
    }
    
    var versionRow: String {
        switch self {
        case .alphabetImage, .alphabetLetterAudio, .alphabetExampleAudio, .questionAudio:
            return "media"
        }
    }
    
    var isDisplayed: Bool {
        switch self {
        case .alphabetImage:
            return true
        case .alphabetLetterAudio, .alphabetExampleAudio, .questionAudio:
            return false
        }
    }
}
