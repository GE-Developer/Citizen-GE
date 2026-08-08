//
//  NavigationLazyView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct NavigationLazyView<Content: View>: View {
    private let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: some View {
        build()
    }
}
