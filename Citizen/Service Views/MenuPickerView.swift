//
//  MenuPickerView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct MenuPickerView: View {
    @Binding private var selection: String
    
    private let options: [String]
    private let emptyString = ""
    
    init(selection: Binding<String>, options: [String]) {
        self._selection = selection
        self.options = options
    }
    
    var body: some View {
        menuPickerView
    }
}

// MARK: - Builder
extension MenuPickerView {
    private var menuPickerView: some View {
        Picker(emptyString, selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(option)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .tag(option)
            }
        }
        .pickerStyle(.menu)
        .tint(Color.citizen.accent)
        .frame(height: 40)
        .background(background)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.citizen.secondaryGroupBackground)
            .shadow(color: Color.citizen.viewShadow, radius: 4)
    }
}
