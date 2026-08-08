//
//  CustomTextField.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomTextField: View {
    @EnvironmentObject private var store: StoreManager
    
    @State private var showPayWall = false
    
    @Binding private var text: String
    @Binding private var isDisabled: Bool
    
    @FocusState private var focus: Bool
    
    private var inputButtonDisabled: Bool {
        !text.isEmpty || isDisabled || hasAttachment || focus
    }
    
    private var sendButtonDisabled: Bool {
        (text.isEmpty && !hasAttachment) || isDisabled
    }
    
    private let height: CGFloat = 40
    private let keyboard: UIKeyboardType
    private let placeholder: String
    private let icon: Image?
    private let isMultilined: Bool
    private let error: Bool
    private let hasAttachment: Bool
    private let inputAction: (() -> Void)?
    private let sendAction: (() -> Void)?
    
    init(
        text: Binding<String>,
        isDisabled: Binding<Bool> = .constant(false),
        keyboard: UIKeyboardType = .default,
        placeholder: String,
        icon: Image? = nil,
        isMultilined: Bool = false,
        error: Bool = false,
        hasAttachment: Bool = false,
        inputAction: (() -> Void)? = nil,
        sendAction: (() -> Void)? = nil
    ) {
        self._text = text
        self._isDisabled = isDisabled
        self.keyboard = keyboard
        self.placeholder = placeholder
        self.icon = icon
        self.isMultilined = isMultilined
        self.error = error
        self.hasAttachment = hasAttachment
        self.inputAction = inputAction
        self.sendAction = sendAction
    }
    
    var body: some View {
        customMessageTextField
            .fullScreenCover(isPresented: $showPayWall) {
                NavigationLazyView(PayWallView(store))
            }
    }
}

// MARK: - Builder
extension CustomTextField {
    private var customMessageTextField: some View {
        HStack(alignment: .bottom) {
            inputButton
            HStack(spacing: 0) {
                fieldImage
                textField
                deleteButton
            }
            .disabled(hasAttachment)
            .background { background }
            
            sendButton
        }
        .disabled(isDisabled)
        .onChange(of: isDisabled) {
            if isDisabled {
                text = ""
            }
        }
    }
    
    @ViewBuilder
    private var fieldImage: some View {
        if let icon {
            icon
                .font(.title3)
                .fontWeight(.ultraLight)
                .padding(.leading, 12)
                .foregroundStyle(
                    focus
                    ? Gradient.accent
                    : Gradient.gray
                )
                .contentShape(Rectangle())
                .onTapGesture { focus = true }
        }
    }
    
    private var textField: some View {
        TextField(placeholder, text: $text, axis: isMultilined ? .vertical : .horizontal)
            .focused($focus)
            .keyboardType(keyboard)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .frame(minHeight: height)
            .lineLimit(isMultilined ? 4 : 1)
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
    
    
    @ViewBuilder
    private var sendButton: some View {
        if let sendAction {
            ZStack {
                Circle()
                    .foregroundStyle(
                        sendButtonDisabled
                        ? Gradient.gray
                        : Gradient.accent
                    )
                Image.system.send
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .opacity(sendButtonDisabled ? 0.6 : 1)
            .frame(width: height, height: height)
            .animation(.easeIn.speed(2), value: sendButtonDisabled)
            .onTapGesture {
                if !sendButtonDisabled {
                    focus = false
                    sendAction()
                }
            }
        }
    }
    
    @ViewBuilder
    private var inputButton: some View {
        if let inputAction {
            Image.system.plus
                .font(.title)
                .foregroundStyle(
                    store.isPremium
                    ? (inputButtonDisabled ? Gradient.gray : Gradient.accent)
                    : Gradient.gold
                )
                .opacity(inputButtonDisabled ? 0.6 : 1)
                .frame(height: height)
                .animation(.easeIn.speed(2), value: inputButtonDisabled)
                .onTapGesture {
                    if !inputButtonDisabled {
                        focus = false
                        HapticsManager.shared.impact(style: .rigid)
                        inputAction()
                    }
                }
                .premiumOption($showPayWall)
        }
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Color.citizen.textFieldBackground)
            .overlay(
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(
                        error ? Color.citizen.redDark.opacity(0.6) : Color.clear,
                        lineWidth: 2
                    )
            )
            .animation(.easeInOut, value: error)
            .shadow(color: Color.citizen.viewShadow, radius: 4)
    }
}

// MARK: - Methods
extension CustomTextField {
    private func deleteButtonPressed() {
        text = ""
    }
}
