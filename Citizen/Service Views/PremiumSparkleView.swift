//
//  PremiumSparkleView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct PremiumSparkleView: View {
    private struct Sparkle {
        let position: UnitPoint
        let size: CGFloat
        let phase: Double
        let period: Double
        let spin: Double
        let drift: CGFloat
    }
    
    private let sparkles: [Sparkle] = [
        .init(
            position: .init(x: 0.06, y: 0.32),
            size: 6,
            phase: 0.0,
            period: 1.9,
            spin: 0.4,
            drift: 2
        ),
        .init(
            position: .init(x: 0.15, y: 0.70),
            size: 5,
            phase: 2.1,
            period: 2.4,
            spin: -0.3,
            drift: 2
        ),
        .init(
            position: .init(x: 0.25, y: 0.24),
            size: 7,
            phase: 3.8,
            period: 2.0,
            spin: 0.35,
            drift: 3
        ),
        .init(
            position: .init(x: 0.36, y: 0.62),
            size: 5,
            phase: 1.2,
            period: 2.6,
            spin: -0.4,
            drift: 2
        ),
        .init(
            position: .init(x: 0.47, y: 0.30),
            size: 6,
            phase: 5.0,
            period: 1.8,
            spin: 0.45,
            drift: 2
        ),
        .init(
            position: .init(x: 0.58, y: 0.72),
            size: 5,
            phase: 0.7,
            period: 2.3,
            spin: -0.35,
            drift: 2
        ),
        .init(
            position: .init(x: 0.69, y: 0.26),
            size: 7,
            phase: 2.7,
            period: 2.1,
            spin: 0.3,
            drift: 3
        ),
        .init(
            position: .init(x: 0.80, y: 0.66),
            size: 6,
            phase: 4.2,
            period: 1.9,
            spin: -0.45,
            drift: 2
        ),
        .init(
            position: .init(x: 0.92, y: 0.36),
            size: 8,
            phase: 1.6,
            period: 2.2,
            spin: 0.4,
            drift: 2
        ),
    ]
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let accent = Color.citizen.accent
                let core = Color.citizen.white
                
                for sparkle in sparkles {
                    draw(sparkle, at: time, in: context, size: size, accent: accent, core: core)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Logic
extension PremiumSparkleView {
    private func draw(
        _ sparkle: Sparkle,
        at time: TimeInterval,
        in context: GraphicsContext,
        size: CGSize,
        accent: Color,
        core: Color
    ) {
        let angular = 2 * Double.pi / sparkle.period
        let twinkle = pow((sin(time * angular + sparkle.phase) + 1) / 2, 1.6)
        
        let scale = 0.4 + 0.6 * twinkle
        let driftX = CGFloat(cos(time * 0.9 + sparkle.phase)) * sparkle.drift
        let driftY = CGFloat(sin(time * 0.7 + sparkle.phase)) * sparkle.drift
        let center = CGPoint(
            x: sparkle.position.x * size.width + driftX,
            y: sparkle.position.y * size.height + driftY
        )
        
        var spinning = context
        spinning.translateBy(x: center.x, y: center.y)
        spinning.rotate(by: .radians(time * sparkle.spin + sparkle.phase))
        spinning.translateBy(x: -center.x, y: -center.y)
        
        fillSparkle(
            in: spinning,
            center: center,
            side: sparkle.size * scale * 1.7,
            blur: 2.6,
            color: accent.opacity(0.28 * twinkle)
        )
        fillSparkle(
            in: spinning,
            center: center,
            side: sparkle.size * scale,
            blur: 0.5,
            color: accent.opacity(0.3 + 0.6 * twinkle)
        )
        fillSparkle(
            in: spinning,
            center: center,
            side: sparkle.size * scale * 0.42,
            blur: 0,
            color: core.opacity(0.85 * twinkle * twinkle)
        )
    }
    
    private func fillSparkle(
        in context: GraphicsContext,
        center: CGPoint,
        side: CGFloat,
        blur: CGFloat,
        color: Color
    ) {
        var layer = context
        
        if blur > 0 {
            layer.addFilter(.blur(radius: blur))
        }
        
        let rect = CGRect(
            x: center.x - side / 2,
            y: center.y - side / 2,
            width: side,
            height: side
        )
        
        layer.fill(SparkleShape().path(in: rect), with: .color(color))
    }
}

private struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let pinch = radius * 0.12
        
        let top = CGPoint(x: center.x, y: center.y - radius)
        let right = CGPoint(x: center.x + radius, y: center.y)
        let bottom = CGPoint(x: center.x, y: center.y + radius)
        let left = CGPoint(x: center.x - radius, y: center.y)
        
        var path = Path()
        path.move(to: top)
        path.addQuadCurve(to: right, control: CGPoint(x: center.x + pinch, y: center.y - pinch))
        path.addQuadCurve(to: bottom, control: CGPoint(x: center.x + pinch, y: center.y + pinch))
        path.addQuadCurve(to: left, control: CGPoint(x: center.x - pinch, y: center.y + pinch))
        path.addQuadCurve(to: top, control: CGPoint(x: center.x - pinch, y: center.y - pinch))
        path.closeSubpath()
        
        return path
    }
}
