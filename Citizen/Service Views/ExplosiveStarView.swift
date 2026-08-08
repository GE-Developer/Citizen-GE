//
//  ExplosiveStarView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExplosiveStarView: View {
    @State private var scaleSmall: CGFloat = 0.0001
    @State private var scaleLarge: CGFloat = 0.0001
    @State private var scaleCircle: CGFloat = 0.0001
    
    let isSelected: Bool
    
    private let image: Image = .system.star
    private let imageFill: Image = .system.star
    
    private let normalColor: Color = .citizen.background
    private let effectColor: Color = .citizen.accent
    
    var body: some View {
        GeometryReader{ proxy in
            let minSize = min(proxy.size.width, proxy.size.width)
            
            ZStack {
                image
                    .font(.system(size: minSize))
                    .fontWeight(.ultraLight)
                    .opacity(isSelected ? 0 : 1)
                    .scaleEffect(isSelected ? 0.0001 : 1)
                    .foregroundStyle(normalColor)
                    .animation(
                        isSelected
                        ? .easeOut(duration: 0)
                        : .spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8),
                        value: isSelected
                    )
                
                imageFill
                    .font(.system(size: minSize))
                    .opacity(isSelected ? 1 : 0)
                    .scaleEffect(isSelected ? 1 : 0.0001)
                    .foregroundStyle(Gradient.accent)
                    .opacity(isSelected ? 1 : 0)
                    .animation(
                        isSelected
                        ? .spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8).delay(0.2)
                        : .easeOut(duration: 0), value: isSelected
                    )
                
                Circle()
                    .stroke(lineWidth: isSelected ? 0 : minSize / 2)
                    .foregroundColor(isSelected ? effectColor : normalColor)
                    .scaleEffect(scaleCircle)
                    .opacity(isSelected ? 1 : 0)
                    .animation(
                        isSelected
                        ? .easeOut(duration: 0.31)
                        : .easeOut(duration: 0), value: isSelected
                    )
                
                ZStack {
                    ExplosiveStarEffect(scale: scaleSmall, tickCount: 7, size: minSize * 0.08)
                        .foregroundColor(isSelected ? effectColor : normalColor)
                        .scaleEffect(isSelected ? 1.6 : 0.0001)
                        .opacity(isSelected ? 1 : 0)
                        .rotationEffect(isSelected ? .degrees(6) : .degrees(24))
                        .animation(
                            isSelected
                            ? .spring(response: 0.28, dampingFraction: 0.8, blendDuration: 0.86).delay(0.10)
                            : .easeOut(duration: 0), value: isSelected
                        )
                    
                    ExplosiveStarEffect(scale: scaleLarge, tickCount: 7, size: minSize * 0.1)
                        .foregroundColor(isSelected ? effectColor : normalColor)
                        .scaleEffect(isSelected ? 2 : 0.0001)
                        .opacity(isSelected ? 1 : 0)
                        .animation(
                            isSelected
                            ? .spring(response: 0.28, dampingFraction: 0.8, blendDuration: 0.86).delay(0.16)
                            : .easeOut(duration: 0), value: isSelected
                        )
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8), value: isSelected)
            .frame(width: minSize, height: minSize, alignment: .center)
            .onChange(of: isSelected) {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.6, blendDuration: 0.8)) {
                    if isSelected {
                        scaleSmall = 1.0
                        scaleLarge = 1.0
                        scaleCircle = 1.6
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            scaleSmall = 0.0001
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            scaleLarge = 0.0001
                        }
                    } else {
                        scaleSmall = 0.0001
                        scaleLarge = 0.0001
                        scaleCircle = 0.0001
                    }
                }
            }
        }
    }
}

// MARK: - Explosive Like Effect
fileprivate struct ExplosiveStarEffect: View {
    private let scale: CGFloat
    private let tickCount: Int
    private let size: CGFloat
    
    init(scale: CGFloat, tickCount: Int, size: CGFloat) {
        self.scale = scale
        self.tickCount = tickCount
        self.size = size
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                ForEach(0 ..< tickCount, id: \.self) { tick in
                    Circle()
                        .scaleEffect(scale)
                        .animation(
                            scale != 1
                            ? .easeInOut(duration: 0.8)
                            : .easeInOut(duration: 0), value: scale
                        )
                        .frame(width: size, height: size)
                        .offset(
                            x: proxy.size.width <= proxy.size.height
                            ? -(proxy.size.width / 2)
                            : -(proxy.size.height / 2 )
                        )
                        .rotationEffect(.degrees(Double(tick) / Double(tickCount)) * 360)
                        .offset(x: -size / 2, y: -size / 2)
                }
            }
            .offset(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
    }
}
