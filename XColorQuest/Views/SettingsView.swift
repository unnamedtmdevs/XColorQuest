//
//  SettingsView.swift
//  ColorQuest
//
//  Settings and preferences management
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(Constants.Storage.soundEnabled) private var soundEnabled = true
    @AppStorage(Constants.Storage.colorBlindMode) private var colorBlindMode = false
    @AppStorage(Constants.Storage.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(Constants.Storage.currentLevel) private var currentLevel = 1
    @AppStorage(Constants.Storage.highestScore) private var highestScore = 0
    @AppStorage(Constants.Storage.totalGamesPlayed) private var totalGamesPlayed = 0
    
    @State private var showingResetAlert = false
    @State private var showingDeleteAlert = false
    @State private var showingPrivacyNotice = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                ColorScheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.Layout.spacing * 1.5) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 60))
                                .foregroundColor(ColorScheme.buttonSecondary)
                            Text("Settings")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(ColorScheme.textPrimary)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .accessibilityAddTraits(.isHeader)
                        
                        // Game Settings Section
                        SettingsSection(title: "Game Settings") {
                            SettingsToggle(
                                icon: "speaker.wave.2.fill",
                                title: "Sound Effects",
                                description: "Play sounds during gameplay",
                                isOn: $soundEnabled
                            )
                            
                            SettingsToggle(
                                icon: "eye.fill",
                                title: "Color Blind Mode",
                                description: "Alternative color palette for better accessibility",
                                isOn: $colorBlindMode
                            )
                        }
                        
                        // Statistics Section
                        SettingsSection(title: "Statistics") {
                            StatisticRow(icon: "trophy.fill", label: "Highest Score", value: "\(highestScore)")
                            StatisticRow(icon: "flag.fill", label: "Current Level", value: "\(currentLevel)")
                            StatisticRow(icon: "gamecontroller.fill", label: "Games Played", value: "\(totalGamesPlayed)")
                        }
                        
                        // Data Management Section
                        SettingsSection(title: "Data Management") {
                            SettingsButton(
                                icon: "arrow.counterclockwise",
                                title: "Reset Game Progress",
                                description: "Return to onboarding and reset all game data",
                                color: ColorScheme.warning,
                                action: {
                                    showingResetAlert = true
                                }
                            )
                            
                            SettingsButton(
                                icon: "trash.fill",
                                title: "Delete Account",
                                description: "Remove all data and start fresh",
                                color: ColorScheme.error,
                                action: {
                                    showingDeleteAlert = true
                                }
                            )
                        }
                        
                        // About Section
                        SettingsSection(title: "About") {
                            SettingsButton(
                                icon: "lock.shield.fill",
                                title: "Privacy Notice",
                                description: "View how your data is handled",
                                color: ColorScheme.buttonPrimary,
                                action: {
                                    showingPrivacyNotice = true
                                }
                            )
                            
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(ColorScheme.buttonSecondary)
                                Text("Version 1.0.0")
                                    .foregroundColor(ColorScheme.textSecondary)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                    .fill(ColorScheme.buttonPrimary.opacity(0.1))
                            )
                        }
                        
                        // Close Button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: Constants.Layout.buttonHeight)
                                .foregroundColor(.white)
                                .background(ColorScheme.buttonPrimary)
                                .cornerRadius(Constants.Layout.cornerRadius)
                        }
                        .padding(.top, Constants.Layout.spacing)
                    }
                    .padding(.horizontal, Constants.Layout.padding)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showingResetAlert) {
            Alert(
                title: Text("Reset Progress?"),
                message: Text("This will reset all game progress and return you to the onboarding screen. This action cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    resetProgress()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingDeleteAlert) {
            deleteAccountConfirmation
        }
        .sheet(isPresented: $showingPrivacyNotice) {
            privacyNoticeView
        }
    }
    
    // MARK: - Delete Account Confirmation
    
    private var deleteAccountConfirmation: some View {
        ZStack {
            ColorScheme.background
                .ignoresSafeArea()
            
            VStack(spacing: Constants.Layout.spacing * 2) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(ColorScheme.error)
                
                Text("Delete Account?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(ColorScheme.textPrimary)
                
                Text("This will permanently delete all your game data, settings, and progress. This action cannot be undone.")
                    .font(.system(size: 16))
                    .foregroundColor(ColorScheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Layout.padding)
                
                VStack(spacing: Constants.Layout.spacing) {
                    Button(action: {
                        deleteAccount()
                    }) {
                        Text("Delete All Data")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: Constants.Layout.buttonHeight)
                            .foregroundColor(.white)
                            .background(ColorScheme.error)
                            .cornerRadius(Constants.Layout.cornerRadius)
                    }
                    
                    Button(action: {
                        showingDeleteAlert = false
                    }) {
                        Text("Cancel")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: Constants.Layout.buttonHeight)
                            .foregroundColor(.white)
                            .background(ColorScheme.buttonSecondary)
                            .cornerRadius(Constants.Layout.cornerRadius)
                    }
                }
                .padding(.horizontal, Constants.Layout.padding)
            }
        }
    }
    
    // MARK: - Privacy Notice View
    
    private var privacyNoticeView: some View {
        NavigationView {
            ZStack {
                ColorScheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Constants.Layout.spacing) {
                        Text(Constants.privacyNotice)
                            .font(.system(size: 16))
                            .foregroundColor(ColorScheme.textPrimary)
                            .lineSpacing(6)
                    }
                    .padding(Constants.Layout.padding)
                }
            }
            .navigationTitle("Privacy Notice")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingPrivacyNotice = false
                    }
                    .foregroundColor(ColorScheme.buttonPrimary)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func resetProgress() {
        currentLevel = 1
        highestScore = 0
        totalGamesPlayed = 0
        hasCompletedOnboarding = false
        presentationMode.wrappedValue.dismiss()
    }
    
    private func deleteAccount() {
        // Reset all app storage
        soundEnabled = true
        colorBlindMode = false
        currentLevel = 1
        highestScore = 0
        totalGamesPlayed = 0
        hasCompletedOnboarding = false
        
        showingDeleteAlert = false
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Supporting Views

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.spacing) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ColorScheme.textSecondary)
                .textCase(.uppercase)
                .accessibilityAddTraits(.isHeader)
            
            VStack(spacing: 12) {
                content
            }
        }
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(ColorScheme.buttonPrimary)
                .frame(width: 30)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ColorScheme.textPrimary)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(ColorScheme.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .fill(ColorScheme.buttonPrimary.opacity(0.1))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ColorScheme.textPrimary)
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(ColorScheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(ColorScheme.textSecondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(ColorScheme.buttonPrimary.opacity(0.1))
            )
        }
        .accessibilityLabel("\(title). \(description)")
    }
}

struct StatisticRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(ColorScheme.accentPrimary)
                .frame(width: 30)
                .accessibilityHidden(true)
            
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(ColorScheme.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(ColorScheme.accentPrimary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .fill(ColorScheme.buttonPrimary.opacity(0.1))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

