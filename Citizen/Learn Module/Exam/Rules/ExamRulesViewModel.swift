//
//  ExamRulesViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ExamRulesViewModel {
    var questionsValue: String {
        "\(ExamConfig.totalQuestions(sections: sectionCount))"
    }
    
    var limitValue: String {
        L10n("\(ExamConfig.fullMinutes(sections: sectionCount)) Main.Exam.preview")
    }
    
    var thresholdValue: String {
        let required = ExamConfig.requiredCorrectTotal(sections: sectionCount)
        return "\(required)/\(ExamConfig.totalQuestions(sections: sectionCount))"
    }
    
    var eligibility: [ExamEligibilityRow] {
        let subjects = repository.catalog.categories
            .sorted { $0.index < $1.index }
            .map(\.name)
        
        return [
            ExamEligibilityRow(
                id: "naturalization",
                title: L10n("Exam.Rules.Who.naturalization"),
                note: L10n("Exam.Rules.Who.naturalizationNote"),
                subjects: subjects
            ),
            ExamEligibilityRow(
                id: "spouse",
                title: L10n("Exam.Rules.Who.spouse"),
                note: L10n("Exam.Rules.Who.spouseNote"),
                subjects: Array(subjects.prefix(2))
            ),
            ExamEligibilityRow(
                id: "restoration",
                title: L10n("Exam.Rules.Who.restoration"),
                note: L10n("Exam.Rules.Who.restorationNote"),
                subjects: Array(subjects.prefix(1))
            ),
            ExamEligibilityRow(
                id: "exempt",
                title: L10n("Exam.Rules.Who.exempt"),
                note: L10n("Exam.Rules.Who.exemptNote"),
                subjects: []
            )
        ]
    }
    
    private var sectionCount: Int {
        repository.catalog.categories.count
    }
    
    let title = L10n("Exam.Rules.title")
    let heroTitle = L10n("Exam.Rules.Hero.title")
    let heroSubtitle = L10n("Exam.Rules.Hero.subtitle")
    let questionsCaption = L10n("Exam.Hero.questions")
    let limitCaption = L10n("Exam.Hero.limit")
    let thresholdCaption = L10n("Exam.Hero.threshold")
    let languageTitle = L10n("Exam.Rules.Language.title")
    let languageText = L10n("Exam.Rules.Language.text")
    let stepsTitle = L10n("Exam.Rules.Steps.title")
    let eligibilityTitle = L10n("Exam.Rules.Who.title")
    let feesTitle = L10n("Exam.Rules.Fees.title")
    let bansTitle = L10n("Exam.Rules.Bans.title")
    let tipsTitle = L10n("Exam.Rules.Tips.title")
    let footer = L10n("Exam.Rules.footer")
    
    let steps: [ExamRuleStep] = [
        ExamRuleStep(
            number: 1,
            title: L10n("Exam.Rules.Step1.title"),
            text: L10n("Exam.Rules.Step1.text")
        ),
        ExamRuleStep(
            number: 2,
            title: L10n("Exam.Rules.Step2.title"),
            text: L10n("Exam.Rules.Step2.text")
        ),
        ExamRuleStep(
            number: 3,
            title: L10n("Exam.Rules.Step3.title"),
            text: L10n("Exam.Rules.Step3.text")
        ),
        ExamRuleStep(
            number: 4,
            title: L10n("Exam.Rules.Step4.title"),
            text: L10n("Exam.Rules.Step4.text")
        ),
        ExamRuleStep(
            number: 5,
            title: L10n("Exam.Rules.Step5.title"),
            text: L10n("Exam.Rules.Step5.text")
        )
    ]
    
    let fees = [
        L10n("Exam.Rules.Fee.first"),
        L10n("Exam.Rules.Fee.retry"),
        L10n("Exam.Rules.Fee.unlimited"),
        L10n("Exam.Rules.Fee.noShow")
    ]
    
    let bans = [
        L10n("Exam.Rules.Ban.materials"),
        L10n("Exam.Rules.Ban.talking"),
        L10n("Exam.Rules.Ban.leaving"),
        L10n("Exam.Rules.Ban.photo")
    ]
    
    let tips: [ExamRuleTip] = [
        ExamRuleTip(
            title: L10n("Exam.Rules.Tip1.title"),
            text: L10n("Exam.Rules.Tip1.text")
        ),
        ExamRuleTip(
            title: L10n("Exam.Rules.Tip2.title"),
            text: L10n("Exam.Rules.Tip2.text")
        ),
        ExamRuleTip(
            title: L10n("Exam.Rules.Tip3.title"),
            text: L10n("Exam.Rules.Tip3.text")
        ),
        ExamRuleTip(
            title: L10n("Exam.Rules.Tip4.title"),
            text: L10n("Exam.Rules.Tip4.text")
        ),
        ExamRuleTip(
            title: L10n("Exam.Rules.Tip5.title"),
            text: L10n("Exam.Rules.Tip5.text")
        )
    ]
    
    private let repository = QuizRepository.shared
    
    init() {}
}

// MARK: - ExamRuleStep
struct ExamRuleStep: Identifiable {
    let number: Int
    let title: String
    let text: String
    
    var id: Int {
        number
    }
}

// MARK: - ExamEligibilityRow
struct ExamEligibilityRow: Identifiable {
    var isExempt: Bool {
        subjects.isEmpty
    }
    
    let id: String
    let title: String
    let note: String
    let subjects: [String]
}

// MARK: - ExamRuleTip
struct ExamRuleTip: Identifiable {
    let title: String
    let text: String
    
    var id: String {
        title
    }
}
