//
//  VoiceHighlightModifier.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct VoiceHighlight: ViewModifier {
    private let isActive: Bool
    private let playbackID: Int
    
    init(isActive: Bool, playbackID: Int) {
        self.isActive = isActive
        self.playbackID = playbackID
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    if isActive {
                        VoiceHighlightWave()
                            .id(playbackID)
                            .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.2), value: isActive)
                .blendMode(.sourceAtop)
                .allowsHitTesting(false)
            }
            .compositingGroup()
    }
}

private struct VoiceHighlightWave: View {
    @State private var slide = false
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            
            LinearGradient(
                stops: [
                    .init(color: Color.citizen.accent.opacity(0), location: 0),
                    .init(color: Color.citizen.accent, location: 0.5),
                    .init(color: Color.citizen.accent.opacity(0), location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: width * 0.6, height: proxy.size.height)
            .offset(x: slide ? width : -width * 0.6)
            .onAppear {
                withAnimation(.linear(duration: 1.4)) {
                    slide = true
                }
            }
        }
    }
}
