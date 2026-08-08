//
//  HapticsManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import UIKit

@MainActor
final class HapticsManager {
    var isHapticsOn: Bool {
        didSet { defaults.set(isHapticsOn, forKey: key) }
    }
    
    static let shared = HapticsManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.haptics.key
    
    private init() {
        isHapticsOn = defaults.object(forKey: key) as? Bool ?? true
    }
    
    func reset() {
        isHapticsOn = true
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium, vol: CGFloat = 1, delay: Double = 0) {
        guard isHapticsOn else { return }
        
        let impactGenerator = UIImpactFeedbackGenerator(style: style)
        impactGenerator.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            impactGenerator.impactOccurred(intensity: vol)
        }
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType, delay: Double = 0) {
        guard isHapticsOn else { return }
        
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            notificationGenerator.notificationOccurred(type)
        }
    }
    
    func selectionChanged(delay: Double = 0) {
        guard isHapticsOn else { return }
        
        let selectionGenerator = UISelectionFeedbackGenerator()
        selectionGenerator.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            selectionGenerator.selectionChanged()
        }
    }
}
