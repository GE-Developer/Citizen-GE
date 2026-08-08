//
//  OccurrenceRow.swift
//  Citizen
//
//  Created by GE-Developer
//

struct OccurrenceRow: Identifiable, Hashable {
    let question: Question
    let categoryName: String
    let topicName: String
    let sentenceSegments: [RichTextSegment]
    let isPremium: Bool
    
    var id: String {
        question.id
    }
    
    var number: String {
        question.number
    }
    
    var questionText: String {
        question.question
    }
    
    var hasSentence: Bool {
        !sentenceSegments.isEmpty
    }
}
