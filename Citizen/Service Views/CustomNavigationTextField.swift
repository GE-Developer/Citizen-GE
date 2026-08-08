//
//  CustomNavigationTextField.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomNavigationTextField: View {
    @Binding var text: String
    
    @FocusState private var focus: Bool
    @State private var isButtonEnabled = false
    @State private var hasAutoFocused = false
    
    private let autoFocused: Bool
    private let image: Image
    private let placeholder: String
    private let cancelButtonTitle: String
    
    private let deleteAction: () -> Void
    
    init(text: Binding<String>,
         isButtonEnabled: Bool = false,
         autoFocused: Bool = false,
         image: Image = .system.magnifyingglass,
         placeholder: String,
         cancelButtonTitle: String = L10n("SearchField.cancel"),
         deleteAction: @escaping () -> Void) {
        _text = text
        self.isButtonEnabled = isButtonEnabled
        self.autoFocused = autoFocused
        self.image = image
        self.placeholder = placeholder
        self.cancelButtonTitle = cancelButtonTitle
        self.deleteAction = deleteAction
    }
    
    var body: some View {
        customNavigationTextField
            .task {
                guard autoFocused, !hasAutoFocused else { return }
                hasAutoFocused = true
                guard (try? await Task.sleep(for: .seconds(0.5))) != nil else { return }
                focus = true
            }
    }
}

// MARK: - Builder
extension CustomNavigationTextField {
    private var customNavigationTextField: some View {
        HStack {
            HStack(spacing: 0) {
                searchImage
                textField
                deleteButton
            }
            .background { background }
            .onTapGesture { focus = true }
            
            if isButtonEnabled {
                cancelButton
            }
        }
        .animation(.easeInOut, value: isButtonEnabled)
        .animation(.easeInOut, value: focus)
    }
    
    private var searchImage: some View {
        image
            .font(.title3)
            .fontWeight(.light)
            .padding(.leading, 10)
            .foregroundStyle(
                focus ? Color.citizen.accent : Color.citizen.grayDark
            )
    }
    
    private var textField: some View {
        TextField(placeholder, text: $text) { isEditing in
            isButtonEnabled = isEditing
        }
        .focused($focus)
        .autocorrectionDisabled(true)
        .padding(.vertical, 5)
        .padding(.horizontal, 5)
        .lineLimit(1)
        .foregroundStyle(Color.citizen.mainText)
        .fontDesign(.rounded)
        .fontWeight(.light)
    }
    
    private var deleteButton: some View {
        Button(action: deleteAction) {
            Image.system.xmark
                .font(.title3)
                .fontWeight(.ultraLight)
                .foregroundStyle(Color.citizen.secondaryText)
                .padding(.trailing, 10)
        }
        .opacity(text.isEmpty ? 0 : 1)
    }
    
    private var cancelButton: some View {
        Button(action: { focus = false }) {
            Text(cancelButtonTitle)
                .foregroundStyle(Color.citizen.secondaryText)
                .lineLimit(1)
                .fontDesign(.rounded)
                .fontWeight(.thin)
                .minimumScaleFactor(0.5)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.citizen.groupBackground)
            .shadow(color: Color.citizen.viewShadow, radius: 2)
            .frame(height: 40)
    }
}
