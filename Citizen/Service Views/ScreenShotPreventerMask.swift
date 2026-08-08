//
//  ScreenShotPreventerMask.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ScreenShotPreventerMask: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UITextField()
        view.isSecureTextEntry = true
        view.text = ""
        view.isUserInteractionEnabled = false
        
        let secureLayer = findAutoHideLayer(view: view) ?? view.layer.sublayers?.last
        secureLayer?.backgroundColor = UIColor.white.cgColor
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
    
    private func findAutoHideLayer(view: UIView) -> CALayer? {
        view.layer.sublayers?.first { layer in
            layer.delegate.debugDescription.contains("UITextLayoutCanvasView")
        }
    }
}
