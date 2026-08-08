//
//  ContactsView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ContactsView: View {
    @State private var vm = ContactsViewModel()
    
    var body: some View {
        content
            .navigationDestination(item: $vm.selectedContact) { contact in
                NavigationLazyView(ContactDetailView(contact: contact))
            }
    }
}

// MARK: - Builder
extension ContactsView {
    private var content: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            switch vm.phase {
            case .loading:
                loadingState
            case .failed:
                failureState
            case .loaded:
                if vm.sections.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
        }
        .task { await vm.load() }
    }
    
    private var list: some View {
        LazyVStack(alignment: .leading, spacing: 25) {
            ForEach(vm.sections) { section in
                VStack(alignment: .leading, spacing: 12) {
                    FormHeaderView(section.title)
                    ForEach(section.contacts) { contact in
                        contactCell(contact)
                    }
                }
            }
        }
    }
    
    private var loadingState: some View {
        ProgressView()
            .tint(Color.citizen.accent)
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: Image.system.contacts,
            title: vm.emptyTitle,
            message: vm.emptyMessage
        )
        .padding(.top, 60)
    }
    
    private var failureState: some View {
        EmptyStateView(
            icon: Image.system.warning,
            title: vm.failureTitle,
            message: vm.emptyMessage
        )
        .padding(.top, 60)
    }
    
    private func contactCell(_ contact: Contact) -> some View {
        Button(action: { vm.select(contact) }) {
            HStack(spacing: 14) {
                RemoteAvatarView(
                    urlString: vm.photoURL(for: contact),
                    size: 54,
                    placeholder: contact.isCompany ? .system.company : .system.person
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Text(vm.displayName(for: contact))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.citizen.mainText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        if contact.isVerified {
                            Image.system.verified
                                .font(.footnote)
                                .foregroundStyle(Gradient.accent)
                        }
                    }
                    
                    Text(vm.subtitle(for: contact) ?? "")
                        .font(.subheadline)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                }
                .fontDesign(.rounded)
                .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image.system.chevron
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .frame(height: 65)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}
