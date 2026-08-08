//
//  Sound.swift
//  Citizen
//
//  Created by GE-Developer
//

enum Sound {
    case devMode
    case errorAlert
    case correctAnswer
    case wrongAnswer
    case success
    
    var name: String {
        switch self {
        case .devMode: return "Dev_Mode"
        case .errorAlert: return "Error_Alert"
        case .correctAnswer: return "Correct_Answer"
        case .wrongAnswer: return "Wrong_Answer"
        case .success: return "Success"
        }
    }
    
    static func answer(isCorrect: Bool) -> Sound {
        isCorrect ? .correctAnswer : .wrongAnswer
    }
}
