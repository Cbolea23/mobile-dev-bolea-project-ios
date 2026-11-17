//
//  CookingModeView.swift
//  midterm project
//
//  Created by Christian Louis on 11/16/26.
//

import SwiftUI
import Combine

struct CookingModeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    let recipe: RecipeItem
    var onFinishCooking: () -> Void
    
    @State private var currentStepIndex: Int = 0
    @State private var showIngredients: Bool = false
    @State private var remainingSeconds: Int = 0
    @State private var isTimerRunning: Bool = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var steps: [String] {
        recipe.instructions.isEmpty
            ? ["Ihanda ang lahat ng sangkap at lutuin ayon sa tamang init."]
            : recipe.instructions
    }
    
    private var isLastStep: Bool {
        currentStepIndex >= steps.count - 1
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Header & Step Progress
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.title)
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(Color.ulamTextDark)
                            
                            HStack {
                                Text("Hakbang \(currentStepIndex + 1) ng \(steps.count)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.ulamOrange)
                                Spacer()
                                Text("\(Int((Double(currentStepIndex + 1) / Double(max(steps.count, 1))) * 100))%")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            
                            ProgressView(
                                value: Double(currentStepIndex + 1),
                                total: Double(max(steps.count, 1))
                            )
                            .tint(.ulamOrange)
                        }
                        
                        // Current Step Card
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("STEP \(currentStepIndex + 1)")
                                    .font(.system(size: 11, weight: .heavy))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.ulamLightOrange)
                                    .foregroundColor(.ulamOrange)
                                    .cornerRadius(8)
                                Spacer()
                            }
                            
                            Text(steps[currentStepIndex])
                                .font(.system(size: 18, weight: .medium))
                                .lineSpacing(5)
                                .foregroundColor(Color.ulamTextDark)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.ulamCard)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.ulamBorder, lineWidth: 1)
                        )
                        
                        // Built-in Cooking Timer
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Cooking Timer", systemImage: "timer")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.ulamTextDark)
                                Spacer()
                                Text(formattedTime(remainingSeconds))
                                    .font(.system(size: 22, weight: .heavy, design: .monospaced))
                                    .foregroundColor(remainingSeconds > 0 ? .ulamOrange : .secondary)
                            }
                            
                            HStack(spacing: 8) {
                                TimerPresetButton(title: "5 min") {
                                    setTimer(seconds: 5 * 60)
                                }
                                TimerPresetButton(title: "10 min") {
                                    setTimer(seconds: 10 * 60)
                                }
                                TimerPresetButton(title: "15 min") {
                                    setTimer(seconds: 15 * 60)
                                }
                            }
                            
                            HStack(spacing: 10) {
                                Button(action: {
                                    if remainingSeconds == 0 {
                                        remainingSeconds = 5 * 60
                                    }
                                    isTimerRunning.toggle()
                                }) {
                                    Label(
                                        isTimerRunning ? "I-pause" : "Simulan",
                                        systemImage: isTimerRunning ? "pause.fill" : "play.fill"
                                    )
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.ulamOrange)
                                    .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    isTimerRunning = false
                                    remainingSeconds = 0
                                }) {
                                    Text("I-reset")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color.ulamTextDark)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.black.opacity(0.06))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.ulamCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.ulamBorder, lineWidth: 1)
                        )
                        
                        // Collapsible Ingredients Checklist
                        if !recipe.ingredients.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showIngredients.toggle()
                                    }
                                }) {
                                    HStack {
                                        Label("Mga Sangkap (\(recipe.ingredients.count))", systemImage: "checklist")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color.ulamTextDark)
                                        Spacer()
                                        Image(systemName: showIngredients ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if showIngredients {
                                    VStack(spacing: 8) {
                                        ForEach(recipe.ingredients, id: \.self) { item in
                                            let isChecked = recipeVM.checkedIngredients.contains(item)
                                            HStack(spacing: 10) {
                                                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(isChecked ? .ulamOrange : .secondary)
                                                Text(item)
                                                    .font(.system(size: 13))
                                                    .strikethrough(isChecked, color: .secondary)
                                                    .foregroundColor(isChecked ? .secondary : Color.ulamTextDark)
                                                Spacer()
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                recipeVM.toggleIngredient(item)
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding(16)
                            .background(Color.ulamCard)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.ulamBorder, lineWidth: 1)
                            )
                        }
                    }
                    .padding(20)
                }
                
                // Bottom Navigation Controls
                HStack(spacing: 12) {
                    Button(action: {
                        if currentStepIndex > 0 {
                            withAnimation { currentStepIndex -= 1 }
                        }
                    }) {
                        Text("Nakaraang")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(currentStepIndex == 0 ? .secondary : Color.ulamTextDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.ulamCard)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.ulamBorder, lineWidth: 1)
                            )
                    }
                    .disabled(currentStepIndex == 0)
                    
                    Button(action: {
                        if isLastStep {
                            onFinishCooking()
                            dismiss()
                        } else {
                            withAnimation { currentStepIndex += 1 }
                        }
                    }) {
                        Text(isLastStep ? "Tapos na ang Pagluluto! 🎉" : "Susunod")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.ulamOrange)
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.ulamCream)
            }
            .background(Color.ulamCream.ignoresSafeArea())
            .navigationTitle("Cooking Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Isara") {
                        isTimerRunning = false
                        dismiss()
                    }
                    .foregroundColor(.ulamOrange)
                }
            }
            .onReceive(timer) { _ in
                guard isTimerRunning else { return }
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    isTimerRunning = false
                }
            }
        }
    }
    
    private func setTimer(seconds: Int) {
        remainingSeconds = seconds
        isTimerRunning = true
    }
    
    private func formattedTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TimerPresetButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.ulamOrange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.ulamLightOrange)
                .cornerRadius(8)
        }
    }
}
