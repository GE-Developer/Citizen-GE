//
//  DeviceLayout.swift
//  Citizen
//
//  Created by GE-Developer
//

import UIKit

@MainActor
enum DeviceLayout {
    static var hasHomeIndicator: Bool {
        if cachedHasHomeIndicator {
            return true
        }
        
        guard let window = keyWindow else {
            return false
        }
        
        let hasIndicator = window.safeAreaInsets.bottom > 0
        if hasIndicator {
            cachedHasHomeIndicator = true
        }
        
        return hasIndicator
    }
    
    static var safeAreaTop: CGFloat {
        if cachedSafeAreaTop > 0 {
            return cachedSafeAreaTop
        }
        
        guard let window = keyWindow else {
            return 0
        }
        
        cachedSafeAreaTop = window.safeAreaInsets.top
        
        return cachedSafeAreaTop
    }
    
    static var safeAreaBottom: CGFloat {
        if cachedSafeAreaBottom > 0 {
            return cachedSafeAreaBottom
        }
        
        guard let window = keyWindow else {
            return 0
        }
        
        cachedSafeAreaBottom = window.safeAreaInsets.bottom
        
        return cachedSafeAreaBottom
    }
    
    static var screenWidth: CGFloat {
        if cachedScreenWidth > 0 {
            return cachedScreenWidth
        }
        
        guard let screen = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.screen })
            .first else {
            return 0
        }
        
        cachedScreenWidth = screen.bounds.width
        
        return cachedScreenWidth
    }
    
    static var screenHeight: CGFloat {
        if cachedScreenHeight > 0 {
            return cachedScreenHeight
        }
        
        guard let screen = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.screen })
            .first else {
            return 0
        }
        
        cachedScreenHeight = screen.bounds.height
        
        return cachedScreenHeight
    }
    
    private static var cachedHasHomeIndicator = false
    private static var cachedScreenWidth: CGFloat = 0
    private static var cachedScreenHeight: CGFloat = 0
    private static var cachedSafeAreaTop: CGFloat = 0
    private static var cachedSafeAreaBottom: CGFloat = 0
    
    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
