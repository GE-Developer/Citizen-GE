//
//  ProgressRing.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ProgressRing: View {
    private let progress: Double
    private let subtitle: String?
    private let withPercent: Bool
    private let lineWidth: CGFloat
    private let isDark: Bool
    
    private var percentText: String { "\(Int(progress * 100))%" }
    
    init(
        progress: Double,
        subtitle: String? = nil,
        withPercent: Bool = true,
        lineWidth: CGFloat = 5,
        isDark: Bool = false
    ) {
        self.progress = progress
        self.subtitle = subtitle
        self.withPercent = withPercent
        self.lineWidth = lineWidth
        self.isDark = isDark
    }
    
    var body: some View {
        progressRing
    }
}

// MARK: - Builder
extension ProgressRing {
    private var progressRing: some View {
        ZStack {
            trackLine
            fillLine
            percentLabel
        }
    }
    
    private var trackLine: some View {
        Circle()
            .stroke(lineWidth: lineWidth)
            .fill(
                isDark
                ? Color.citizen.darkGroupBackground
                : Color.citizen.groupBackground
            )
    }
    
    private var fillLine: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(style: .init(lineWidth: lineWidth, lineCap: .round))
            .fill(Gradient.accent)
            .rotationEffect(.degrees(-90))
    }
    
    private var percentLabel: some View {
        VStack {
            if withPercent {
                Text(percentText)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(
                        subtitle == nil
                        ? AnyShapeStyle(Gradient.accent)
                        : AnyShapeStyle(Color.citizen.mainText)
                    )
            }
            if let subtitle {
                Text(subtitle.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.secondaryText)
                    .tracking(1.5)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal)
            }
        }
        .fontDesign(.rounded)
    }
}
