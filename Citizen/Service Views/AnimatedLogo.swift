//
//  AnimatedLogo.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AnimatedLogo: View {
    @State private var typedText = ""
    
    private var visibleText: String { isAnimated ? typedText : Self.text }
    
    private let isAnimated: Bool
    
    private static let text = "CITIZEN"
    private static let suffixText = "GE"
    private static let letters = Array(text.enumerated())
    private static let markIndex = 1
    private static let naturalWordSize: CGFloat = 28
    
    private static let letterSpacing: CGFloat = 4.8 / 28
    private static let shadowRadius: CGFloat = 0 / 28
    private static let suffixSize: CGFloat = 17 / 28
    private static let suffixKerning: CGFloat = 0.80
    private static let suffixGap: CGFloat = 5.3 / 28
    private static let markHeight: CGFloat = 14 / 28
    private static let markGap: CGFloat = 4.4 / 28
    private static let markOffsetX: CGFloat = 3 / 28
    private static let markAspectRatio: CGFloat = 300 / 230
    
    private static let descent: CGFloat = 300 / 1000
    private static let capToAscent: CGFloat = (915 - 700) / 1000
    private static let lineHeight: CGFloat = (915 + 300 + 23) / 1000
    
    private static let markOverhang = max(0, markHeight + markGap - capToAscent)
    private static let suffixTrim = descent + suffixSize * capToAscent
    
    private static let wordLine = Font.citizen.bicubikMetrics(
        of: text,
        size: 1,
        kerning: letterSpacing
    )
    private static let suffixLine = Font.citizen.bicubikMetrics(
        of: suffixText,
        size: suffixSize,
        kerning: letterSpacing * suffixKerning
    )
    private static let suffixOverhang = wordLine.trailingGap - suffixLine.trailingGap
    private static let trailingTrim = wordLine.trailingGap
    private static let bottomTrim = suffixLine.bottomGap
    
    private static let unitWidth = max(wordLine.box, suffixLine.box + suffixOverhang) - trailingTrim
    private static let unitHeight = markOverhang + lineHeight + (suffixGap - suffixTrim) + suffixSize * lineHeight - bottomTrim
    private static let natural = CGSize(
        width: unitWidth * naturalWordSize,
        height: unitHeight * naturalWordSize
    )
    
    private static let typingDelay = Duration.milliseconds(150)
    private static let erasingDelay = Duration.milliseconds(80)
    private static let holdDelay = Duration.seconds(1.2)
    private static let restartDelay = Duration.milliseconds(400)
    
    init(withAnimation: Bool = true) {
        self.isAnimated = withAnimation
    }
    
    var body: some View {
        logo
            .task(id: isAnimated) { try? await animate() }
    }
}

// MARK: - Builder
extension AnimatedLogo {
    private var logo: some View {
        GeometryReader { proxy in
            lockup(proxy.size.width / Self.unitWidth)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(idealWidth: Self.natural.width, idealHeight: Self.natural.height)
        .aspectRatio(Self.unitWidth / Self.unitHeight, contentMode: .fit)
    }
    
    private func lockup(_ wordSize: CGFloat) -> some View {
        VStack(
            alignment: .trailing,
            spacing: wordSize * (Self.suffixGap - Self.suffixTrim)
        ) {
            word(wordSize)
            suffix(wordSize)
        }
        .padding(.top, wordSize * Self.markOverhang)
        .padding(.trailing, -wordSize * Self.trailingTrim)
        .padding(.bottom, -wordSize * Self.bottomTrim)
    }
    
    private func word(_ wordSize: CGFloat) -> some View {
        Text(Self.text)
            .foregroundStyle(Color.citizen.mainText)
            .opacity(0.1)
            .overlay(alignment: .leading) {
                Text(visibleText)
                    .foregroundStyle(Color.citizen.mainText)
                    .shadow(
                        color: Color.citizen.mainText,
                        radius: wordSize * Self.shadowRadius
                    )
                    .fixedSize()
            }
            .font(.citizen.bicubik(wordSize))
            .kerning(wordSize * Self.letterSpacing)
            .lineLimit(1)
            .overlay(alignment: .topLeading) { markRuler(wordSize) }
    }
    
    private func markRuler(_ wordSize: CGFloat) -> some View {
        HStack(spacing: wordSize * Self.letterSpacing) {
            ForEach(Self.letters, id: \.offset) { index, letter in
                Text(String(letter))
                    .hidden()
                    .overlay(alignment: .top) {
                        if index == Self.markIndex { mark(wordSize) }
                    }
            }
        }
        .font(.citizen.bicubik(wordSize))
        .kerning(0)
        .lineLimit(1)
        .accessibilityHidden(true)
    }
    
    private func suffix(_ wordSize: CGFloat) -> some View {
        Text(Self.suffixText)
            .font(.citizen.bicubik(wordSize * Self.suffixSize))
            .kerning(wordSize * Self.letterSpacing * Self.suffixKerning)
            .foregroundStyle(Gradient.accent)
            .lineLimit(1)
            .padding(.trailing, wordSize * Self.suffixOverhang)
    }
    
    @ViewBuilder
    private func mark(_ wordSize: CGFloat) -> some View {
        let height = wordSize * Self.markHeight
        
        Image.other.checkmark
            .resizable()
            .frame(width: height * Self.markAspectRatio, height: height)
            .foregroundStyle(Gradient.accent)
            .offset(
                x: wordSize * Self.markOffsetX,
                y: wordSize * Self.capToAscent - height - wordSize * Self.markGap
            )
    }
}

// MARK: - Logic
extension AnimatedLogo {
    private func animate() async throws {
        guard isAnimated else { return }
        typedText = ""
        
        while true {
            for index in Self.text.indices {
                typedText = String(Self.text[...index])
                try await Task.sleep(for: Self.typingDelay)
            }
            try await Task.sleep(for: Self.holdDelay)
            
            while !typedText.isEmpty {
                typedText.removeLast()
                try await Task.sleep(for: Self.erasingDelay)
            }
            try await Task.sleep(for: Self.restartDelay)
        }
    }
}
