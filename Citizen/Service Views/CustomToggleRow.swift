//
//  CustomToggleRow.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomToggleRow: View {
    @Binding var isOn: Bool
    
    private let icon: Image?
    private let title: String
    private let subtitle: String?
    private let haptics = HapticsManager.shared
    
    init(isOn: Binding<Bool>, icon: Image? = nil, title: String, subtitle: String? = nil) {
        _isOn = isOn
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        customToggleRow
            .onChange(of: isOn) {
                haptics.selectionChanged()
            }
    }
}

// MARK: - Builder
extension CustomToggleRow {
    @ViewBuilder
    private var customToggleRow: some View {
        HStack(spacing: 0) {
            Group {
                Group {
                    if let icon {
                        icon
                            .foregroundStyle(Gradient.accent)
                            .frame(width: 50)
                    } else {
                        Color.clear
                            .frame(width: 0)
                            .padding(.leading, 16)
                    }
                }
                titleColumn
            }
            .padding(.vertical, subtitle == nil ? 16 : 6)
            Spacer()
            toggle
        }
    }
    
    private var titleColumn: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .foregroundStyle(Color.citizen.mainText)
                .font(.headline)
                .fontWeight(.regular)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(Color.citizen.secondaryText)
                    .font(.caption)
                    .fontWeight(.light)
            }
        }
        .fontDesign(.rounded)
        .multilineTextAlignment(.leading)
        .padding(.trailing)
    }
    
    private var toggle: some View {
        Button {
            withAnimation { isOn.toggle() }
        } label: {
            RoundedRectangle(cornerRadius: 16)
                .fill(isOn ? Gradient.accent : Gradient.gray)
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.citizen.white)
                        .frame(width: 24, height: 24)
                        .offset(x: isOn ? 10 : -10)
                        .animation(.easeInOut(duration: 0.2), value: isOn)
                )
        }
        .padding(.trailing)
    }
}
