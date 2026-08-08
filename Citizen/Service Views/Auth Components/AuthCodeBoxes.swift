//
//  AuthCodeBoxes.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AuthCodeBoxes: View {
    @Binding private var code: String
    
    private var isFocused: FocusState<Bool>.Binding
    
    private let length: Int
    private let isDisabled: Bool
    
    init(
        code: Binding<String>,
        length: Int,
        isFocused: FocusState<Bool>.Binding,
        isDisabled: Bool
    ) {
        self._code = code
        self.length = length
        self.isFocused = isFocused
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        codeBoxes
    }
}

// MARK: - Builder
extension AuthCodeBoxes {
    private var codeBoxes: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused(isFocused)
                .frame(width: 1, height: 1)
                .opacity(0.0001)
            
            HStack(spacing: 10) {
                ForEach(0..<length, id: \.self) { index in
                    codeBox(index)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { isFocused.wrappedValue = true }
        }
        .frame(maxWidth: .infinity)
        .disabled(isDisabled)
    }
    
    @ViewBuilder
    private func codeBox(_ index: Int) -> some View {
        let digits = Array(code)
        let isActive = isFocused.wrappedValue && index == min(code.count, length - 1)
        
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.citizen.groupBackground)
            .frame(height: 56)
            .frame(maxWidth: 56)
            .overlay {
                Text(index < digits.count ? String(digits[index]) : "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? Color.citizen.accent : .clear, lineWidth: 1.5)
            }
    }
}
