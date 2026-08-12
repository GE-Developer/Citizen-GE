//
//  ExamConfig.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

enum ExamConfig {
    static let questionsPerSection = 10
    static let sectionDuration: TimeInterval = 20 * 60
    static let passThresholdPercent = 70
    
    static var sectionMinutes: Int {
        Int(sectionDuration) / 60
    }
    
    static func sampleCount(available: Int) -> Int {
        min(questionsPerSection, available)
    }
    
    static func requiredCorrect(of total: Int) -> Int {
        (total * passThresholdPercent + 99) / 100
    }
    
    static func requiredCorrectTotal(sections: Int) -> Int {
        requiredCorrect(of: questionsPerSection) * sections
    }
    
    static func fullMinutes(sections: Int) -> Int {
        sections * sectionMinutes
    }
    
    static func totalQuestions(sections: Int) -> Int {
        sections * questionsPerSection
    }
}
