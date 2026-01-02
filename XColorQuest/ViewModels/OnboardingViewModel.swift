//
//  OnboardingViewModel.swift
//  ColorQuest
//
//  ViewModel for onboarding flow
//

import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var isCompleted: Bool = false
    
    let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "Welcome to ColorQuest",
            description: "A unique puzzle game that challenges your memory and pattern recognition skills!",
            imageName: "brain.head.profile",
            color: ColorScheme.buttonPrimary
        ),
        OnboardingStep(
            title: "How to Play",
            description: "Watch the color pattern carefully, then recreate it from memory. Each correct answer advances you to the next level!",
            imageName: "eye.fill",
            color: ColorScheme.buttonSecondary
        ),
        OnboardingStep(
            title: "Ready to Play?",
            description: "Patterns get longer and time gets shorter as you progress. Challenge yourself and see how far you can go!",
            imageName: "gamecontroller.fill",
            color: ColorScheme.accentPrimary
        )
    ]
    
    var currentOnboardingStep: OnboardingStep {
        steps[currentStep]
    }
    
    var isLastStep: Bool {
        currentStep == steps.count - 1
    }
    
    func nextStep() {
        if currentStep < steps.count - 1 {
            withAnimation(.easeInOut) {
                currentStep += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            withAnimation(.easeInOut) {
                currentStep -= 1
            }
        }
    }
    
    func skipOnboarding() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        withAnimation {
            isCompleted = true
        }
    }
}

struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: Color
    var isPractice: Bool = false
}

