//
//  ContentView.swift
//  X:ColorQuest
//
//  Created by Simon Bakhanets on 31.12.2025.
//  Main content view with navigation
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var showingGame = false
    @State private var showingSettings = false
    @State private var showingPrivacyNotice = false
    @AppStorage(Constants.Storage.highestScore) private var highestScore: Int = 0
    @AppStorage(Constants.Storage.totalGamesPlayed) private var totalGamesPlayed: Int = 0
    
    var body: some View {
        ZStack {
            // Background
            ColorScheme.background
                .ignoresSafeArea()
            
            VStack(spacing: Constants.Layout.spacing * 2) {
                Spacer()
                
                // Title
                VStack(spacing: 8) {
                    Text("ColorQuest")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(ColorScheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Memory • Patterns • Colors")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ColorScheme.textSecondary)
                }
                .padding(.bottom, 20)
                
                // Stats Card
                VStack(spacing: 12) {
                    HStack(spacing: 40) {
                        StatView(title: "High Score", value: "\(highestScore)")
                        StatView(title: "Games Played", value: "\(totalGamesPlayed)")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                        .fill(ColorScheme.buttonPrimary.opacity(0.2))
                )
                .padding(.horizontal, Constants.Layout.padding)
                
                Spacer()
                
                // Buttons
                VStack(spacing: Constants.Layout.spacing) {
                    // Play Button
                    Button(action: {
                        showingGame = true
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.title2)
                            Text("Start Game")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.Layout.buttonHeight)
                        .foregroundColor(.white)
                        .background(ColorScheme.buttonPrimary)
                        .cornerRadius(Constants.Layout.cornerRadius)
                    }
                    .accessibilityLabel("Start new game")
                    .accessibilityHint("Starts a new ColorQuest game")
                    
                    // Settings Button
                    Button(action: {
                        showingSettings = true
                    }) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                            Text("Settings")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.Layout.buttonHeight)
                        .foregroundColor(.white)
                        .background(ColorScheme.buttonSecondary)
                        .cornerRadius(Constants.Layout.cornerRadius)
                    }
                    .accessibilityLabel("Open settings")
                    
                    // Privacy Notice Button
                    Button(action: {
                        showingPrivacyNotice = true
                    }) {
                        Text("Privacy Notice")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ColorScheme.textSecondary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, Constants.Layout.padding)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingGame) {
            GameView(viewModel: gameViewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .alert(isPresented: $showingPrivacyNotice) {
            Alert(
                title: Text("Privacy Notice"),
                message: Text(Constants.privacyNotice),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(ColorScheme.accentPrimary)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ColorScheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview {
    ContentView()
}
