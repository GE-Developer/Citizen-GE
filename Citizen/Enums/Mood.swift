//
//  Mood.swift
//  Citizen
//
//  Created by GE-Developer
//

enum Mood: String, CaseIterable, Sendable {
    case fire = "🔥"
    case flow = "🧠"
    case focus = "🎯"
    case rocket = "🚀"
    case coffee = "☕️"
    case ready = "💪"
    case calm = "😎"
    case excited = "🤩"
    case party = "🥳"
    case thinking = "🤔"
    case sleepy = "😴"
    case melting = "🫠"
    
    var emoji: String { rawValue }
    
    @MainActor
    var title: String {
        switch self {
        case .fire: L10n("Mood.fire")
        case .flow: L10n("Mood.flow")
        case .focus: L10n("Mood.focus")
        case .rocket: L10n("Mood.rocket")
        case .coffee: L10n("Mood.coffee")
        case .ready: L10n("Mood.ready")
        case .calm: L10n("Mood.calm")
        case .excited: L10n("Mood.excited")
        case .party: L10n("Mood.party")
        case .thinking: L10n("Mood.thinking")
        case .sleepy: L10n("Mood.sleepy")
        case .melting: L10n("Mood.melting")
        }
    }
}
