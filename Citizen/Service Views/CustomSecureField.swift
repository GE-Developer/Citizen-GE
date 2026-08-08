//
//  CustomSecureField.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomSecureField: View {
    @State private var isRevealed = false
    @State private var isFocused = false
    
    @Binding private var password: String
    
    private let placeholder: String
    private let isNewPassword: Bool
    private let height: CGFloat = 45
    private let cornerRadius: CGFloat = 16
    private let haptics = HapticsManager.shared
    
    init(
        password: Binding<String>,
        placeholder: String,
        isNewPassword: Bool = false
    ) {
        self._password = password
        self.placeholder = placeholder
        self.isNewPassword = isNewPassword
    }
    
    var body: some View {
        customSecureFieldRow
    }
}

// MARK: - Builder
extension CustomSecureField {
    private var customSecureFieldRow: some View {
        HStack(spacing: 0) {
            image
            secureField
            revealButton
        }
        .background { background }
        .onTapGesture { isFocused = true }
    }
    
    private var image: some View {
        Image.system.lock
            .font(.title3)
            .fontWeight(.ultraLight)
            .frame(width: 50)
            .foregroundStyle(
                isFocused
                ? Gradient.accent
                : Gradient.secondaryText
            )
            .animation(.easeOut, value: isFocused)
    }
    
    private var secureField: some View {
        SecureInputField(
            text: $password,
            isFocused: $isFocused,
            placeholder: placeholder,
            isSecure: !isRevealed,
            isNewPassword: isNewPassword
        )
        .frame(height: height)
    }
    
    private var revealButton: some View {
        Button(action: toggleReveal) {
            Image.system.eye(isRevealed)
                .font(.title3)
                .fontWeight(.ultraLight)
                .foregroundStyle(Color.citizen.secondaryText)
                .padding(.trailing, 14)
        }
        .opacity(password.isEmpty ? 0 : 1)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.citizen.groupBackground)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isFocused ? Color.citizen.accent : .clear, lineWidth: 1.5)
            )
            .animation(.easeOut, value: isFocused)
    }
}

// MARK: - Logic
extension CustomSecureField {
    private func toggleReveal() {
        haptics.impact(style: .light)
        isRevealed.toggle()
    }
}

// MARK: - SecureInputField
private struct SecureInputField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    
    let placeholder: String
    let isSecure: Bool
    let isNewPassword: Bool
    
    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.placeholder = placeholder
        field.isSecureTextEntry = isSecure
        field.textContentType = isNewPassword ? .newPassword : .password
        field.keyboardType = .asciiCapable
        field.returnKeyType = .done
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.spellCheckingType = .no
        field.textColor = UIColor(Color.citizen.mainText)
        field.font = Self.font
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.addTarget(
            context.coordinator,
            action: #selector(Coordinator.editingChanged),
            for: .editingChanged
        )
        field.inputAccessoryView = context.coordinator.makeDoneBar()
        return field
    }
    
    func updateUIView(_ field: UITextField, context: Context) {
        context.coordinator.parent = self
        
        if field.text != text {
            field.text = text
        }
        if field.isSecureTextEntry != isSecure {
            field.isSecureTextEntry = isSecure
            preserveTextAfterSecureToggle(field)
        }
        syncFocus(field)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    private func preserveTextAfterSecureToggle(_ field: UITextField) {
        guard field.isFirstResponder, let current = field.text, !current.isEmpty else {
            return
        }
        
        field.text = ""
        field.insertText(current)
    }
    
    private func syncFocus(_ field: UITextField) {
        if isFocused, !field.isFirstResponder, field.window != nil {
            field.becomeFirstResponder()
        } else if !isFocused, field.isFirstResponder {
            field.resignFirstResponder()
        }
    }
    
    private static var font: UIFont {
        let base = UIFont.systemFont(ofSize: 17, weight: .light)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else {
            return base
        }
        
        return UIFont(descriptor: descriptor, size: 17)
    }
}

// MARK: - Coordinator
extension SecureInputField {
    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SecureInputField
        
        init(parent: SecureInputField) {
            self.parent = parent
        }
        
        @objc func editingChanged(_ field: UITextField) {
            parent.text = field.text ?? ""
        }
        
        func textFieldDidBeginEditing(_ field: UITextField) {
            if !parent.isFocused {
                parent.isFocused = true
            }
        }
        
        func textFieldDidEndEditing(_ field: UITextField) {
            if parent.isFocused {
                parent.isFocused = false
            }
        }
        
        func textFieldShouldReturn(_ field: UITextField) -> Bool {
            field.resignFirstResponder()
            return true
        }
        
        @MainActor
        func makeDoneBar() -> UIToolbar {
            let bar = UIToolbar()
            bar.tintColor = UIColor(Color.citizen.accent)
            bar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(
                    title: L10n("Keyboard.done"),
                    style: .done,
                    target: self,
                    action: #selector(donePressed)
                )
            ]
            bar.sizeToFit()
            return bar
        }
        
        @MainActor
        @objc private func donePressed() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}
