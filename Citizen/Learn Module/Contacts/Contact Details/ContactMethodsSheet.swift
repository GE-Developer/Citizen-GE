//
//  ContactMethodsSheet.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ContactMethodsSheet: View {
    @Environment(\.openURL) private var openURL
    
    @Bindable private var vm: ContactDetailViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    init(vm: ContactDetailViewModel) {
        _vm = Bindable(vm)
    }
    
    var body: some View {
        sheetBody
            .safeAreaInset(edge: .bottom) { addButton }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.citizen.background)
            .alert(vm.accessAlertTitle, isPresented: $vm.showAccessAlert) {
                Button(vm.openSettingsTitle, action: openSettings)
                Button(vm.cancelTitle, role: .cancel) {}
            } message: {
                Text(vm.accessAlertMessage)
            }
            .alert(vm.saveErrorTitle, isPresented: $vm.showSaveError) {}
    }
}

// MARK: - Builder
extension ContactMethodsSheet {
    private var sheetBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            ScrollView { grid }
                .scrollIndicators(.hidden)
        }
        .padding(.top)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var header: some View {
        HStack(alignment: .bottom) {
            Text(vm.methodsTitle)
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            ExitButton()
        }
    }
    
    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(vm.methods) { method in
                methodCell(method)
            }
        }
    }
    
    private var addButton: some View {
        LinkButton(
            icon: vm.isSaved ? .system.checkmark : .system.addToContacts,
            title: vm.isSaved ? vm.addedToPhoneTitle : vm.addToPhoneTitle,
            isAccent: true,
            action: { Task { await vm.addToPhoneContactsPressed() } }
        )
        .disabled(vm.isSaved || vm.isSaving)
        .padding(.horizontal)
        .padding(.top, 8)
        .background(Color.citizen.background.ignoresSafeArea(edges: .bottom))
    }
    
    private func methodCell(_ method: ContactMethod) -> some View {
        Button(action: { open(method) }) {
            VStack(spacing: 8) {
                icon(for: method.kind)
                    .font(.title2)
                    .foregroundStyle(Gradient.accent)
                
                Text(method.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.mainText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity, minHeight: 84)
            .padding(12)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

// MARK: - Logic
extension ContactMethodsSheet {
    private func icon(for kind: ContactMethodKind) -> Image {
        switch kind {
        case .phone:
            return .system.phone
        case .whatsapp:
            return .system.whatsapp
        case .telegram:
            return .system.telegram
        case .instagram:
            return .other.instagram
        case .email:
            return .system.envelope
        case .website:
            return .system.website
        case .address:
            return .system.mapPin
        }
    }
    
    private func open(_ method: ContactMethod) {
        vm.methodPressed()
        openURL(method.url)
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        openURL(url)
    }
}
