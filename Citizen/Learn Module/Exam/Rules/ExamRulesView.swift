//
//  ExamRulesView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExamRulesView: View {
    @State private var vm = ExamRulesViewModel()

    var body: some View {
        rules
    }
}

// MARK: - Builder
extension ExamRulesView {
    private var rules: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            LazyVStack(spacing: 28) {
                heroCard
                languageCallout
                stepsSection
                eligibilitySection
                feesSection
                bansSection
                tipsSection
                footerNote
            }
        }
    }

    private var heroCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 10) {
                Image.system.graduationCap
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.citizen.white)
                    .frame(width: 56, height: 56)
                    .background {
                        Circle()
                            .fill(Gradient.accent)
                    }

                Text(vm.heroTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.citizen.mainText)

                Text(vm.heroSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.citizen.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .fontDesign(.rounded)

            ExamStatsStrip(
                stats: [
                    ExamHeroStat(value: vm.questionsValue, caption: vm.questionsCaption),
                    ExamHeroStat(value: vm.limitValue, caption: vm.limitCaption),
                    ExamHeroStat(value: vm.thresholdValue, caption: vm.thresholdCaption, isAccent: true)
                ]
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.citizen.groupBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Gradient.accent.opacity(0.12))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Gradient.accent.opacity(0.45), lineWidth: 1)
        }
    }

    private var languageCallout: some View {
        HStack(alignment: .top, spacing: 14) {
            iconBadge(.system.language, color: Color.citizen.accent)

            VStack(alignment: .leading, spacing: 4) {
                Text(vm.languageTitle)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.citizen.mainText)

                Text(vm.languageText)
                    .font(.footnote)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .fontDesign(.rounded)
            .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.citizen.groupBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(vm.stepsTitle)

            VStack(spacing: 0) {
                ForEach(vm.steps) { step in
                    stepRow(step, isLast: step.id == vm.steps.last?.id)
                }
            }
        }
    }

    private var eligibilitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(vm.eligibilityTitle)

            VStack(spacing: 0) {
                ForEach(Array(vm.eligibility.enumerated()), id: \.element.id) { index, row in
                    if index > 0 {
                        Divider()
                            .padding(.leading, 16)
                    }

                    eligibilityRow(row)
                }
            }
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }

    private var feesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(vm.feesTitle)

            VStack(spacing: 0) {
                ForEach(Array(vm.fees.enumerated()), id: \.offset) { index, fee in
                    if index > 0 {
                        Divider()
                            .padding(.leading, 16)
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Gradient.accent)
                            .frame(width: 7, height: 7)
                            .padding(.top, 6)

                        Text(fee)
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color.citizen.mainText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                }
            }
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }

    private var bansSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(vm.bansTitle)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(vm.bans.enumerated()), id: \.offset) { _, ban in
                    HStack(alignment: .top, spacing: 12) {
                        Image.system.xmark
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.citizen.redLight)
                            .frame(width: 20, height: 20)
                            .background {
                                Circle()
                                    .fill(Color.citizen.redLight.opacity(0.15))
                            }

                        Text(ban)
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color.citizen.mainText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.citizen.redLight.opacity(0.1))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.citizen.redLight.opacity(0.3), lineWidth: 1)
            }
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(vm.tipsTitle)

            VStack(spacing: 12) {
                ForEach(vm.tips) { tip in
                    tipCard(tip)
                }
            }
        }
    }

    private var footerNote: some View {
        Text(vm.footer)
            .font(.caption)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func stepRow(_ step: ExamRuleStep, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                numberBadge(step.number)

                if !isLast {
                    Capsule()
                        .fill(Color.citizen.darkGroupBackground)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.citizen.mainText)

                Text(step.text)
                    .font(.footnote)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .fontDesign(.rounded)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.bottom, isLast ? 0 : 12)
        }
    }

    private func numberBadge(_ number: Int) -> some View {
        Text(verbatim: "\(number)")
            .font(.subheadline)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.white)
            .frame(width: 34, height: 34)
            .background {
                Circle()
                    .fill(Gradient.accent)
            }
    }

    private func eligibilityRow(_ row: ExamEligibilityRow) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(row.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.mainText)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                if !row.isExempt {
                    Text(row.note)
                        .font(.caption)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .lineLimit(1)
                        .layoutPriority(1)
                }
            }

            HStack(spacing: 6) {
                if row.isExempt {
                    chip(row.note, color: Color.citizen.greenLight)
                } else {
                    ForEach(row.subjects) { subject in
                        chip(subject.title, color: color(for: subject))
                    }
                }
            }
        }
        .fontDesign(.rounded)
        .padding(16)
    }

    private func tipCard(_ tip: ExamRuleTip) -> some View {
        HStack(alignment: .top, spacing: 14) {
            iconBadge(.system.hint, color: Color.citizen.yellowLight)

            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.citizen.mainText)

                Text(tip.text)
                    .font(.footnote)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .fontDesign(.rounded)
            .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.citizen.groupBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private func iconBadge(_ icon: Image, color: Color) -> some View {
        icon
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: 24, height: 24)
            .padding(10)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func chip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

// MARK: - Logic
extension ExamRulesView {
    private func color(for subject: ExamSubject) -> Color {
        switch subject {
        case .language:
            return Color.citizen.greenLight
        case .history:
            return Color.citizen.redLight
        case .law:
            return Color.citizen.yellowLight
        }
    }
}
