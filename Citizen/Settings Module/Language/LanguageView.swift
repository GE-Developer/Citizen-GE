//
//  LanguageView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct LanguageView: View {
    @State private var vm = LanguageViewModel()
    
    @State private var isShowingAlert = false
    
    init() {
        UIScrollView.appearance().delaysContentTouches = false
    }
    
    var body: some View {
        languageView
    }
}

// MARK: - Builder
extension LanguageView {
    private var languageView: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            CustomForm {
                let languages = Array(Language.allCases.enumerated())
                
                ForEach(languages, id: \.element.id) {
                    languageButtonTapped($0, $1)
                }
            }
        }
        .alert(
            Text(vm.alertTitle),
            isPresented: $isShowingAlert,
            actions: { languageAlertActions },
            message: { Text(vm.alertMessage) }
        )
    }
    
    private func languageButtonTapped(_ index: Int, _ language: Language) -> some View {
        VStack(spacing: 0) {
            CustomButtonRow(
                title: language.localizedName,
                subtitle: language.englishName,
                withCheckmark: vm.isWithCheckmark(language),
                action: {
                    isShowingAlert.toggle()
                    vm.chosenLanguage = language
                }
            )
            if index < Language.allCases.count - 1 {
                Divider()
                    .padding(.leading, 20)
            }
        }
    }
    
    private var languageAlertActions: some View {
        Group {
            Button(vm.alertActionTitle, role: .destructive) {
                vm.setNewLanguage()
            }
            Button(vm.alertCancelTitle, role: .cancel) {}
        }
    }
}
