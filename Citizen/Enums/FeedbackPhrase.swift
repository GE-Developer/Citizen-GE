//
//  FeedbackPhrase.swift
//  Citizen
//
//  Created by GE-Developer
//

@MainActor
enum FeedbackPhrase {
    private static let correctKeys: [String.LocalizationValue] = [
        "FeedbackPhrase.Correct.1",
        "FeedbackPhrase.Correct.2",
        "FeedbackPhrase.Correct.3",
        "FeedbackPhrase.Correct.4",
        "FeedbackPhrase.Correct.5",
        "FeedbackPhrase.Correct.6",
        "FeedbackPhrase.Correct.7",
        "FeedbackPhrase.Correct.8",
        "FeedbackPhrase.Correct.9",
        "FeedbackPhrase.Correct.10"
    ]
    
    private static let wrongKeys: [String.LocalizationValue] = [
        "FeedbackPhrase.Wrong.1",
        "FeedbackPhrase.Wrong.2",
        "FeedbackPhrase.Wrong.3",
        "FeedbackPhrase.Wrong.4",
        "FeedbackPhrase.Wrong.5",
        "FeedbackPhrase.Wrong.6",
        "FeedbackPhrase.Wrong.7",
        "FeedbackPhrase.Wrong.8",
        "FeedbackPhrase.Wrong.9",
        "FeedbackPhrase.Wrong.10"
    ]
    
    static func random(correct: Bool) -> String {
        guard let key = (correct ? correctKeys : wrongKeys).randomElement() else { return "" }
        return L10n(key)
    }
}
