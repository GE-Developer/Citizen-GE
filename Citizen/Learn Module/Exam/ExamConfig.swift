//
//  ExamConfig.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

enum ExamConfig {
    static let fullDurationMin = 60
    static let totalQuestions = 30
    static let subjectDurationMin = 20
    static let requiredCorrect = 7
    static let categoryCount = 3
    
    static var questionsPerSubject: Int {
        totalQuestions / categoryCount
    }
}
