//
//  ExamResultsView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ExamResultsView: View {
    private let vm: ExamSessionViewModel
    private let dismiss: () -> Void
    
    init(vm: ExamSessionViewModel, dismiss: @escaping () -> Void) {
        self.vm = vm
        self.dismiss = dismiss
    }
    
    var body: some View {
        results
    }
}

// MARK: - Builder
extension ExamResultsView {
    private var results: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)
            verdictHeader
            Spacer(minLength: 25)
            sectionList
            pointsLine
            Spacer(minLength: 25)
            buttons
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.citizen.background
                .ignoresSafeArea()
        }
    }
    
    private var verdictHeader: some View {
        VStack(spacing: 14) {
            verdictIcon
            
            Text(vm.verdictTitle)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.citizen.mainText)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 4) {
                Text(vm.scoreText)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.citizen.mainText)
                
                Text(vm.resultsCaption.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(1)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
        }
        .fontDesign(.rounded)
        .lineLimit(2)
        .minimumScaleFactor(0.6)
    }
    
    private var verdictIcon: some View {
        icon
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(verdictColor)
            .frame(width: 84, height: 84)
            .background(verdictColor.opacity(0.15))
            .clipShape(Circle())
    }
    
    private var sectionList: some View {
        VStack(spacing: 0) {
            ForEach(Array(vm.resultRows.enumerated()), id: \.element.id) { index, row in
                if index > 0 {
                    Divider()
                        .padding(.leading, 16)
                }
                
                resultRow(row)
            }
        }
        .background(Color.citizen.groupBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private var pointsLine: some View {
        Text(vm.pointsText)
            .font(.headline)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .foregroundStyle(
                vm.pointsDelta >= 0
                ? Color.citizen.greenLight
                : Color.citizen.redLight
            )
            .padding(.top, 16)
    }
    
    private var buttons: some View {
        VStack(spacing: 4) {
            Button(action: dismiss) {
                Text(vm.doneTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Gradient.accent)
                    }
                    .foregroundStyle(Color.citizen.white)
            }
            
            Button(action: { vm.restart() }) {
                Text(vm.retryTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.secondaryText)
                    .padding()
            }
        }
        .fontDesign(.rounded)
    }
    
    private func resultRow(_ row: ExamResultRow) -> some View {
        HStack(spacing: 10) {
            Text(row.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.citizen.mainText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.7)
            
            Spacer(minLength: 8)
            
            Text(row.score)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(rowColor(row))
            
            rowIcon(row)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(rowColor(row))
        }
        .fontDesign(.rounded)
        .padding(16)
    }
}

// MARK: - Logic
extension ExamResultsView {
    private var icon: Image {
        vm.isPassed ? Image.system.verified : Image.system.xmark
    }
    
    private var verdictColor: Color {
        vm.isPassed ? Color.citizen.greenLight : Color.citizen.redLight
    }
    
    private func rowIcon(_ row: ExamResultRow) -> Image {
        row.isPassed ? Image.system.checkmark : Image.system.xmark
    }
    
    private func rowColor(_ row: ExamResultRow) -> Color {
        row.isPassed ? Color.citizen.greenLight : Color.citizen.redLight
    }
}
