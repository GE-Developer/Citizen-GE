//
//  CustomMessageTextField.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomMessageTextField: View {
    @Binding private var text: String
    @Binding private var isDisabled: Bool
    
    @FocusState private var focus: Bool
    
    private var buttonDisabled: Bool {
        text.isEmpty || isDisabled
    }
    
    private let height: CGFloat = 37
    private let placeholder: String
    private let sendAction: () -> Void
    
    init(
        _ text: Binding<String>,
        _ isDisabled: Binding<Bool>,
        _ placeholder: String,
        _ sendAction: @escaping () -> Void
    ) {
        self._text = text
        self._isDisabled = isDisabled
        self.placeholder = placeholder
        self.sendAction = sendAction
    }
    
    var body: some View {
        customMessageTextField
    }
}

// MARK: - Builder
extension CustomMessageTextField {
    private var customMessageTextField: some View {
        HStack(alignment: .bottom) {
            HStack(spacing: 0) {
                textField
                deleteButton
            }
            .background { background }
            .onTapGesture { focus = true }
            
            sendButton
        }
        .disabled(isDisabled)
        .onChange(of: isDisabled) {
            if isDisabled {
                text = ""
            }
        }
    }
    
    private var textField: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .focused($focus)
            .padding(.vertical, 5)
            .padding(.trailing, 5)
            .padding(.leading, 13)
            .frame(minHeight: height)
            .lineLimit(4)
            .foregroundStyle(Color.citizen.mainText)
            .fontDesign(.rounded)
            .fontWeight(.light)
            .shadow(color: Color.citizen.viewShadow, radius: 2)
    }
    
    private var deleteButton: some View {
        Button(action: deleteButtonPressed) {
            Image.system.xmark
                .font(.title3)
                .fontWeight(.ultraLight)
                .foregroundStyle(Color.citizen.secondaryText)
                .padding(.trailing, 10)
        }
        .opacity(text.isEmpty ? 0 : 1)
    }
    
    
    private var sendButton: some View {
        ZStack {
            Circle()
                .foregroundStyle(
                    buttonDisabled
                    ? Gradient.gray
                    : Gradient.accent
                )
            Image.system.send
                .foregroundStyle(Color.citizen.secondaryText)
        }
        .opacity(buttonDisabled ? 0.6 : 1)
        .frame(width: height, height: height)
        .animation(.easeIn.speed(2), value: buttonDisabled)
        .onTapGesture {
            if !buttonDisabled {
                focus = false
                sendAction()
            }
        }
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Color.citizen.textFieldBackground)
            .shadow(color: Color.citizen.viewShadow, radius: 4)
    }
}

// MARK: - Methods
extension CustomMessageTextField {
    private func deleteButtonPressed() {
        text = ""
    }
}
