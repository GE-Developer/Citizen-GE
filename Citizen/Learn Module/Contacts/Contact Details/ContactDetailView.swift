//
//  ContactDetailView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ContactDetailView: View {
    @State private var vm: ContactDetailViewModel
    
    init(contact: Contact) {
        _vm = State(initialValue: ContactDetailViewModel(contact: contact))
    }
    
    var body: some View {
        content
            .sheet(isPresented: $vm.showMethods) {
                ContactMethodsSheet(vm: vm)
            }
    }
}

// MARK: - Builder
extension ContactDetailView {
    private var content: some View {
        CustomScrollView(title: vm.title, subTitle: vm.categoryTitle) {
            EmptyView()
        } content: { _ in
            VStack(spacing: 12) {
                header
                price
                workingHours
                languages
                about
                contactInfoButton
                
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            RemoteAvatarView(
                urlString: vm.photoURL,
                size: 104,
                placeholder: vm.isCompany ? Image.system.company : Image.system.person
            )
            
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text(vm.heading)
                        .font(.title2)
                        .fontWeight(.bold)
                    if vm.isVerified {
                        Image.system.verified
                            .font(.title3)
                            .foregroundStyle(Gradient.accent)
                    }
                }
                
                if let affiliation = vm.affiliation {
                    Text(affiliation)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.citizen.secondaryText)
                }
                
                if let subtitle = vm.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.citizen.secondaryText)
                }
            }
            .multilineTextAlignment(.center)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var price: some View {
        if let priceText = vm.priceText {
            infoBlock(title: vm.priceTitle) {
                Text(priceText)
            }
        }
    }
    
    @ViewBuilder
    private var workingHours: some View {
        if let workingHours = vm.workingHours {
            infoBlock(title: vm.hoursTitle) {
                Text(workingHours)
            }
        }
    }
    
    @ViewBuilder
    private var languages: some View {
        if let languagesText = vm.languagesText {
            infoBlock(title: vm.languagesTitle) {
                Text(languagesText)
            }
        }
    }
    
    @ViewBuilder
    private var about: some View {
        if let about = vm.about {
            infoBlock(title: vm.aboutTitle) {
                Text(about.asMarkdown)
            }
        }
    }
    
    @ViewBuilder
    private var contactInfoButton: some View {
        if !vm.methods.isEmpty {
            LinkButton(
                icon: .system.contactInfo,
                title: vm.methodsTitle,
                isAccent: true,
                action: { vm.contactInfoButtonPressed() }
            )
        }
    }
    
    private func infoBlock<Body: View>(title: String, @ViewBuilder _ body: () -> Body) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            FormHeaderView(title)
            
            body()
                .font(.subheadline)
                .foregroundStyle(Color.citizen.mainText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 5)
        }
        .fontDesign(.rounded)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.citizen.groupBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
