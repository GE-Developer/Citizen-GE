//
//  CustomTabSection.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomTabSection: View {
    private var activeScreenWidth: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let scene = scenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        ?? scenes.compactMap { $0 as? UIWindowScene }.first
        return scene?.screen.bounds.width ?? 0
    }
    
    private let image: Image
    private let text: String?
    private let subtext: String?
    private let action: () -> Void
    
    init(
        image: Image,
        text: String? = nil,
        subtext: String? = nil,
        action: @escaping () -> Void
    ) {
        self.image = image
        self.text = text
        self.subtext = subtext
        self.action = action
    }
    
    var body: some View {
        customTabSection
    }
}

// MARK: - Builder
extension CustomTabSection {
    private var customTabSection: some View {
        GeometryReader {
            let screenWidth = max(activeScreenWidth, 1)
            let minX = $0.frame(in: .global).minX
            let safeMinX = minX.isFinite ? minX : 0
            let distance = min(1.0, max(0.0, Double(abs(safeMinX) / screenWidth)))
            let direction: Double = safeMinX >= 0 ? 1.0 : -1.0
            let angle = Angle(degrees: -direction * distance * 25.0)
            let scale = 1.0 - distance * 0.08
            let midX = $0.frame(in: .global).midX
            let safeMidX = midX.isFinite ? midX : 0
            let slideRaw = (safeMidX - screenWidth / 2) / screenWidth
            let slide = max(-1.0, min(1.0, Double(slideRaw)))
            let shineOffset = CGFloat(slide) * 240.0
            let shineOpacity = 0.18 + 0.22 * abs(slide)
            
            VStack {
                ZStack {
                    image
                        .resizable()
                        .scaledToFill()
                    titleText
                }
                .frame(height: 180)
                .overlay(blick(shineOpacity, shineOffset))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(stroke)
                .shadow(color: .viewShadow, radius: 2)
                .scaleEffect(CGFloat(scale))
                .rotation3DEffect(
                    angle,
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .center,
                    perspective: 0.7
                )
                .padding(.top, 5)
                .onTapGesture(perform: action)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    private var titleText: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    if let text {
                        Text(text)
                            .font(.title2)
                            .fontWeight(.black)
                        if let subtext {
                            Text(subtext)
                                .font(.headline)
                                .fontWeight(.regular)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(subtextBackground)
                        }
                    }
                }
                .foregroundStyle(Color.citizen.white)
                .fontDesign(.rounded)
                .padding(12)
                Spacer()
            }
        }
        .frame(height: 180)
    }
    
    private var subtextBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(.ultraThinMaterial)
            .opacity(0.95)
            .shadow(
                color: Color(.secondarySystemGroupedBackground),
                radius: 0.5
            )
    }
    
    private var stroke: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color(.secondarySystemGroupedBackground), lineWidth: 1)
    }
    
    private func blick(_ shineOpacity: Double, _ shineOffset: CGFloat) -> some View {
        LinearGradient(
            colors: [
                Color.citizen.white.opacity(0.0),
                Color.citizen.white.opacity(shineOpacity),
                Color.citizen.white.opacity(0.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: 80)
        .rotationEffect(.degrees(22))
        .offset(x: shineOffset)
        .blur(radius: 15)
        .blendMode(.screen)
    }
}
