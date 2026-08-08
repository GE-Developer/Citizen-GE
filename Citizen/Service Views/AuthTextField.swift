//
//  AuthTextField.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AuthTextField: View {
    @FocusState private var focus: Bool
    
    @Binding private var text: String
    
    private let placeholder: String
    private let icon: Image
    private let keyboard: UIKeyboardType
    private let contentType: UITextContentType?
    private let height: CGFloat = 45
    private let cornerRadius: CGFloat = 16
    
    init(
        text: Binding<String>,
        placeholder: String,
        icon: Image,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.keyboard = keyboard
        self.contentType = contentType
    }
    
    var body: some View {
        authTextFieldRow
    }
}

// MARK: - Builder
extension AuthTextField {
    private var authTextFieldRow: some View {
        HStack(spacing: 0) {
            image
            textField
        }
        .background { background }
        .onTapGesture { focus = true }
    }
    
    private var image: some View {
        icon
            .font(.title3)
            .fontWeight(.ultraLight)
            .frame(width: 50)
            .foregroundStyle(
                focus
                ? Gradient.accent
                : Gradient.secondaryText
            )
            .animation(.easeOut, value: focus)
    }
    
    private var textField: some View {
        TextField(placeholder, text: $text)
            .focused($focus)
            .frame(height: height)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .textContentType(contentType)
            .keyboardType(keyboard)
            .padding(.trailing, 14)
            .foregroundStyle(Color.citizen.mainText)
            .submitLabel(.done)
            .onSubmit { focus = false }
            .fontDesign(.rounded)
            .fontWeight(.light)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.citizen.groupBackground)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(focus ? Color.citizen.accent : .clear, lineWidth: 1.5)
                    .animation(.easeOut, value: focus)
            )
    }
}
