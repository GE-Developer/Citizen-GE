//
//  ShimmerModifier.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct Shimmer: ViewModifier {
    @State private var animate = false
    
    private let duration: Double = 1.1
    private let bandOpacity: Double = 0.55
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.30),
                            .init(color: Color.citizen.white.opacity(bandOpacity), location: 0.5),
                            .init(color: .clear, location: 0.70)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geo.size.width * 2, height: geo.size.height * 2)
                    .offset(
                        x: animate ? 0 : -geo.size.width,
                        y: animate ? 0 : -geo.size.height
                    )
                    .blendMode(.plusLighter)
                }
            }
            .mask(content)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
    }
}
