//
//  SaveQuestionSheet.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct SaveQuestionSheet: View {
    @StateObject private var vm: SaveQuestionViewModel
    
    @FocusState private var isNameFieldFocused: Bool
    
    init(question: Question, onChange: @escaping () -> Void) {
        _vm = StateObject(
            wrappedValue: SaveQuestionViewModel(question: question, onChange: onChange)
        )
    }
    
    var body: some View {
        sheetBody
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }
}

// MARK: - Builder
extension SaveQuestionSheet {
    private var sheetBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                Text(vm.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                ExitButton()
            }
            
            Text(vm.subtitle)
                .font(.callout)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.leading)
            
            createFolderRow
            foldersSection
        }
        .ignoresSafeArea()
        .padding(.top)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var foldersSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(vm.foldersHeader.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .tracking(1)
                .foregroundStyle(Color.citizen.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            ScrollView {
                LazyVStack(spacing: 8) {
                    if vm.folders.isEmpty {
                        EmptyFoldersView(text: vm.emptyFoldersText)
                            .padding(.top, 40)
                    }
                    ForEach(vm.folders) { folder in
                        folderRow(folder)
                    }
                    Color.clear
                        .frame(height: 20)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var createFolderRow: some View {
        HStack(spacing: 12) {
            Image.system.plus
                .font(.title3)
                .foregroundStyle(Gradient.accent)
            
            TextField(vm.newFolderTitle, text: $vm.newFolderName)
                .font(.title3)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .focused($isNameFieldFocused)
                .submitLabel(.done)
                .onSubmit(vm.createFolderAndSave)
            
            Button(action: createFolderPressed) {
                ZStack {
                    Image.system.checkmark
                        .foregroundStyle(Color.citizen.secondaryText)
                        .opacity(0.6)
                    Image.system.checkmark
                        .foregroundStyle(Gradient.green)
                        .opacity(vm.canCreateFolder ? 1 : 0)
                }
                .font(.subheadline)
                .fontWeight(.regular)
                .animation(.smooth, value: vm.canCreateFolder)
            }
            .disabled(!vm.canCreateFolder)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background { createFolderBackground }
        .contentShape(Rectangle())
        .onTapGesture { isNameFieldFocused = true }
    }
    
    @ViewBuilder
    private var createFolderBackground: some View {
        if isNameFieldFocused || vm.canCreateFolder {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.citizen.groupBackground)
        } else {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    Color.citizen.secondaryText.opacity(0.3),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6])
                )
        }
    }
    
    private func folderRow(_ folder: QuestionFolder) -> some View {
        let isSaved = vm.isSaved(in: folder)
        return Button(action: { vm.toggleFolder(folder) }) {
            HStack(spacing: 12) {
                Image.system.folder
                    .font(.title3)
                    .foregroundStyle(Gradient.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text(folder.name)
                        .font(.title3)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.mainText)
                    Text(vm.folderCountText(folder))
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.secondaryText)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                Spacer()
                Image.system.checkmarkInCircle(isSaved)
                    .font(.title3)
                    .foregroundStyle(checkmarkStyle(isSaved))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.citizen.groupBackground)
            }
        }
        .transaction {
            $0.disablesAnimations = true
            $0.animation = nil
        }
    }
}

// MARK: - Logic
extension SaveQuestionSheet {
    private func createFolderPressed() {
        vm.createFolderAndSave()
        isNameFieldFocused = false
    }
    
    private func checkmarkStyle(_ isSaved: Bool) -> AnyShapeStyle {
        isSaved
        ? AnyShapeStyle(Gradient.green)
        : AnyShapeStyle(Color.citizen.secondaryText.opacity(0.6))
    }
}
