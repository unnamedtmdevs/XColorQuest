//
//  OnboardingView.swift
//  ColorQuest
//
//  Onboarding flow with interactive tutorial
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @AppStorage(Constants.Storage.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @State private var practicePattern: [PatternColor] = []
    @State private var practiceSelection: [PatternColor] = []
    @State private var showingPattern = false
    @State private var isPracticeComplete = false
    
    var body: some View {
        ZStack {
            // Background
            ColorScheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Indicator
                progressIndicator
                    .padding(.top, 40)
                    .padding(.horizontal, Constants.Layout.padding)
                
                Spacer()
                
                // Content
                if viewModel.currentOnboardingStep.isPractice {
                    practiceView
                } else {
                    onboardingStepView
                }
                
                Spacer()
                
                // Navigation Buttons
                navigationButtons
                    .padding(.horizontal, Constants.Layout.padding)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            if viewModel.currentOnboardingStep.isPractice {
                setupPractice()
            }
        }
        .onChange(of: viewModel.isCompleted) { completed in
            if completed {
                hasCompletedOnboarding = true
            }
        }
        .onChange(of: viewModel.currentStep) { _ in
            if viewModel.currentOnboardingStep.isPractice {
                setupPractice()
            }
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.steps.count, id: \.self) { index in
                Capsule()
                    .fill(index <= viewModel.currentStep ? ColorScheme.accentPrimary : ColorScheme.textSecondary.opacity(0.3))
                    .frame(height: 4)
                    .frame(maxWidth: index == viewModel.currentStep ? 40 : .infinity)
                    .animation(.easeInOut, value: viewModel.currentStep)
            }
        }
        .accessibilityLabel("Step \(viewModel.currentStep + 1) of \(viewModel.steps.count)")
    }
    
    // MARK: - Onboarding Step View
    
    private var onboardingStepView: some View {
        VStack(spacing: Constants.Layout.spacing * 2) {
            // Icon
            Image(systemName: viewModel.currentOnboardingStep.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(viewModel.currentOnboardingStep.color)
                .accessibilityHidden(true)
            
            // Title
            Text(viewModel.currentOnboardingStep.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(ColorScheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            // Description
            Text(viewModel.currentOnboardingStep.description)
                .font(.system(size: 18))
                .foregroundColor(ColorScheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, Constants.Layout.padding)
        }
        .padding(.horizontal, Constants.Layout.padding)
    }
    
    // MARK: - Practice View
    
    private var practiceView: some View {
        VStack(spacing: Constants.Layout.spacing * 2) {
            // Icon
            Image(systemName: isPracticeComplete ? "checkmark.circle.fill" : "hand.tap.fill")
                .font(.system(size: 80, weight: .light))
                .foregroundColor(isPracticeComplete ? ColorScheme.success : ColorScheme.buttonPrimary)
                .accessibilityHidden(true)
            
            // Title
            Text(isPracticeComplete ? "Great Job!" : viewModel.currentOnboardingStep.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(ColorScheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            if !isPracticeComplete {
                // Description
                Text(viewModel.currentOnboardingStep.description)
                    .font(.system(size: 18))
                    .foregroundColor(ColorScheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Layout.padding)
                
                // Practice Pattern Display
                VStack(spacing: Constants.Layout.spacing) {
                    Text(showingPattern ? "Memorize this:" : "Your turn:")
                        .font(.title3.bold())
                        .foregroundColor(ColorScheme.textPrimary)
                    
                    HStack(spacing: Constants.Layout.gameGridSpacing) {
                        if showingPattern {
                            // Show pattern
                            ForEach(practicePattern) { color in
                                ZStack {
                                    Circle()
                                        .fill(color.color)
                                        .frame(width: Constants.Layout.patternCircleSize, height: Constants.Layout.patternCircleSize)
                                    
                                    Text(color.symbol)
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(color.name == "White" ? ColorScheme.background : .white)
                                    
                                    Circle()
                                        .stroke(ColorScheme.accentSecondary, lineWidth: 2)
                                        .frame(width: Constants.Layout.patternCircleSize, height: Constants.Layout.patternCircleSize)
                                }
                                .accessibilityLabel("\(color.name) \(color.symbol)")
                            }
                        } else {
                            // Show user selection
                            ForEach(0..<practicePattern.count, id: \.self) { index in
                                if index < practiceSelection.count {
                                    ZStack {
                                        Circle()
                                            .fill(practiceSelection[index].color)
                                            .frame(width: Constants.Layout.patternCircleSize, height: Constants.Layout.patternCircleSize)
                                        
                                        Text(practiceSelection[index].symbol)
                                            .font(.system(size: 30, weight: .bold))
                                            .foregroundColor(practiceSelection[index].name == "White" ? ColorScheme.background : .white)
                                        
                                        Circle()
                                            .stroke(ColorScheme.accentSecondary, lineWidth: 2)
                                            .frame(width: Constants.Layout.patternCircleSize, height: Constants.Layout.patternCircleSize)
                                    }
                                    .accessibilityLabel("\(practiceSelection[index].name) \(practiceSelection[index].symbol)")
                                } else {
                                    Circle()
                                        .stroke(ColorScheme.textSecondary.opacity(0.3), lineWidth: 2)
                                        .frame(width: Constants.Layout.patternCircleSize, height: Constants.Layout.patternCircleSize)
                                        .accessibilityLabel("Empty slot")
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                        .fill(ColorScheme.buttonPrimary.opacity(0.15))
                )
                
                if !showingPattern {
                    // Practice Color Selection
                    let availableColors = ColorSchemeType.normal.availableColors.prefix(4)
                    HStack(spacing: Constants.Layout.gameGridSpacing) {
                        ForEach(Array(availableColors), id: \.id) { color in
                            Button(action: {
                                selectPracticeColor(color)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(color.color)
                                        .frame(width: 60, height: 60)
                                    
                                    Text(color.symbol)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(color.name == "White" ? ColorScheme.background : .white)
                                    
                                    Circle()
                                        .stroke(ColorScheme.accentSecondary, lineWidth: 2)
                                        .frame(width: 60, height: 60)
                                }
                            }
                            .accessibilityLabel("Select \(color.name) \(color.symbol)")
                        }
                    }
                }
            } else {
                Text("You've mastered the basics! Ready to start your ColorQuest journey?")
                    .font(.system(size: 18))
                    .foregroundColor(ColorScheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Layout.padding)
            }
        }
        .padding(.horizontal, Constants.Layout.padding)
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        VStack(spacing: Constants.Layout.spacing) {
            // Next/Get Started Button
            Button(action: {
                if viewModel.currentOnboardingStep.isPractice && !isPracticeComplete {
                    // Don't allow skipping practice
                } else {
                    viewModel.nextStep()
                }
            }) {
                Text(buttonText)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: Constants.Layout.buttonHeight)
                    .foregroundColor(.white)
                    .background(buttonColor)
                    .cornerRadius(Constants.Layout.cornerRadius)
            }
            .disabled(viewModel.currentOnboardingStep.isPractice && !isPracticeComplete)
            .opacity((viewModel.currentOnboardingStep.isPractice && !isPracticeComplete) ? 0.5 : 1.0)
            
            // Skip Button
            if !viewModel.isLastStep && !viewModel.currentOnboardingStep.isPractice {
                Button(action: {
                    viewModel.skipOnboarding()
                }) {
                    Text("Skip")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ColorScheme.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupPractice() {
        practiceSelection = []
        isPracticeComplete = false
        showingPattern = true
        
        // Generate a simple 3-color pattern
        let availableColors = ColorSchemeType.normal.availableColors.prefix(4)
        practicePattern = Array(availableColors.shuffled().prefix(3))
        
        // Hide pattern after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showingPattern = false
            }
        }
    }
    
    private func selectPracticeColor(_ color: PatternColor) {
        guard practiceSelection.count < practicePattern.count else { return }
        
        practiceSelection.append(color)
        
        // Check if complete
        if practiceSelection.count == practicePattern.count {
            checkPracticeCompletion()
        }
    }
    
    private func checkPracticeCompletion() {
        var isCorrect = true
        for (index, color) in practicePattern.enumerated() {
            if practiceSelection[index].name != color.name {
                isCorrect = false
                break
            }
        }
        
        if isCorrect {
            withAnimation {
                isPracticeComplete = true
            }
        } else {
            // Reset and try again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    practiceSelection = []
                }
            }
        }
    }
    
    private var buttonText: String {
        if viewModel.isLastStep {
            return "Get Started!"
        } else if viewModel.currentOnboardingStep.isPractice {
            return isPracticeComplete ? "Continue" : "Complete Practice"
        } else {
            return "Next"
        }
    }
    
    private var buttonColor: Color {
        if viewModel.isLastStep {
            return ColorScheme.accentPrimary
        } else if viewModel.currentOnboardingStep.isPractice {
            return isPracticeComplete ? ColorScheme.success : ColorScheme.buttonPrimary.opacity(0.5)
        } else {
            return ColorScheme.buttonPrimary
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

