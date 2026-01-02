//
//  GameView.swift
//  ColorQuest
//
//  Main game interface
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingQuitAlert = false
    
    var body: some View {
        ZStack {
            // Background
            ColorScheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                gameHeader
                    .padding(.horizontal, Constants.Layout.padding)
                    .padding(.top, Constants.Layout.padding)
                
                Spacer()
                
                // Main Content
                if viewModel.gameState == .gameOver {
                    gameOverView
                } else {
                    gameContentView
                }
                
                Spacer()
                
                // Controls
                if viewModel.gameState == .playing {
                    controlsView
                        .padding(.horizontal, Constants.Layout.padding)
                }
                
                // Color Selection Grid
                if viewModel.gameState == .playing {
                    colorSelectionGrid
                        .padding(.horizontal, Constants.Layout.padding)
                        .padding(.bottom, Constants.Layout.padding)
                } else if viewModel.gameState == .ready || viewModel.gameState == .gameOver {
                    startButton
                        .padding(.horizontal, Constants.Layout.padding)
                        .padding(.bottom, Constants.Layout.padding)
                }
            }
        }
        .onAppear {
            if viewModel.gameState == .ready {
                // Auto-start when entering view
            }
        }
        .alert(isPresented: $showingQuitAlert) {
            Alert(
                title: Text("Quit Game?"),
                message: Text("Your progress will be saved."),
                primaryButton: .destructive(Text("Quit")) {
                    viewModel.cleanup()
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Header
    
    private var gameHeader: some View {
        HStack {
            // Quit Button
            Button(action: {
                showingQuitAlert = true
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(ColorScheme.textSecondary)
            }
            .accessibilityLabel("Quit game")
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(ColorScheme.textSecondary)
                Text("\(viewModel.score)")
                    .font(.title2.bold())
                    .foregroundColor(ColorScheme.accentPrimary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Score: \(viewModel.score)")
        }
    }
    
    // MARK: - Game Content
    
    private var gameContentView: some View {
        VStack(spacing: Constants.Layout.spacing * 2) {
            // Level and Lives
            HStack(spacing: 40) {
                InfoBadge(
                    icon: "flag.fill",
                    label: "Level",
                    value: "\(viewModel.level)"
                )
                
                InfoBadge(
                    icon: "heart.fill",
                    label: "Lives",
                    value: "\(viewModel.lives)",
                    color: viewModel.lives <= 1 ? ColorScheme.error : ColorScheme.success
                )
            }
            
            // Pattern Display Area
            patternDisplayArea
            
            // Feedback Message
            if !viewModel.feedbackMessage.isEmpty {
                Text(viewModel.feedbackMessage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(viewModel.gameState == .correct ? ColorScheme.success : ColorScheme.error)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Timer or Status
            statusView
        }
        .padding(.horizontal, Constants.Layout.padding)
    }
    
    private var patternDisplayArea: some View {
        VStack(spacing: Constants.Layout.spacing) {
            Text(stateTitle)
                .font(.title2.bold())
                .foregroundColor(ColorScheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            
            // Pattern or User Selection
            HStack(spacing: Constants.Layout.gameGridSpacing) {
                if viewModel.showingPattern, let pattern = viewModel.currentPattern {
                    // Show the pattern
                    ForEach(pattern.colors) { color in
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
                } else if viewModel.gameState == .playing || viewModel.gameState == .correct || viewModel.gameState == .incorrect {
                    // Show user's selection
                    ForEach(0..<(viewModel.currentPattern?.sequenceLength ?? 0), id: \.self) { index in
                        if index < viewModel.userSelection.count {
                            ZStack {
                                Circle()
                                    .fill(viewModel.userSelection[index].color)
                                    .frame(width: Constants.Layout.patternCircleSize, height: Constants.Layout.patternCircleSize)
                                
                                Text(viewModel.userSelection[index].symbol)
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(viewModel.userSelection[index].name == "White" ? ColorScheme.background : .white)
                                
                                Circle()
                                    .stroke(ColorScheme.accentSecondary, lineWidth: 2)
                                    .frame(width: Constants.Layout.patternCircleSize, height: Constants.Layout.patternCircleSize)
                            }
                            .accessibilityLabel("\(viewModel.userSelection[index].name) \(viewModel.userSelection[index].symbol)")
                        } else {
                            Circle()
                                .stroke(ColorScheme.textSecondary.opacity(0.3), lineWidth: 2)
                                .frame(width: Constants.Layout.patternCircleSize, height: Constants.Layout.patternCircleSize)
                                .accessibilityLabel("Empty slot")
                        }
                    }
                } else {
                    // Placeholder
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .stroke(ColorScheme.textSecondary.opacity(0.3), lineWidth: 2)
                            .frame(width: Constants.Layout.patternCircleSize, height: Constants.Layout.patternCircleSize)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 100)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .fill(ColorScheme.buttonPrimary.opacity(0.15))
        )
    }
    
    private var statusView: some View {
        Group {
            if viewModel.gameState == .memorizing {
                VStack(spacing: 8) {
                    Text("Time to remember")
                        .font(.caption)
                        .foregroundColor(ColorScheme.textSecondary)
                    Text(String(format: "%.1f", viewModel.memoryTimeRemaining))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(ColorScheme.accentPrimary)
                        .monospacedDigit()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Time remaining: \(String(format: "%.1f", viewModel.memoryTimeRemaining)) seconds")
            } else if viewModel.gameState == .showing {
                Text("Watch carefully!")
                    .font(.title3.bold())
                    .foregroundColor(ColorScheme.warning)
            } else if viewModel.gameState == .playing {
                Text("Select the pattern")
                    .font(.title3.bold())
                    .foregroundColor(ColorScheme.textPrimary)
            }
        }
    }
    
    // MARK: - Controls
    
    private var controlsView: some View {
        HStack {
            Button(action: {
                viewModel.removeLastSelection()
            }) {
                HStack {
                    Image(systemName: "arrow.uturn.backward")
                    Text("Undo")
                }
                .frame(height: 44)
                .padding(.horizontal, 20)
                .background(ColorScheme.buttonSecondary.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(Constants.Layout.cornerRadius)
            }
            .disabled(viewModel.userSelection.isEmpty)
            .opacity(viewModel.userSelection.isEmpty ? 0.5 : 1.0)
            .accessibilityLabel("Undo last color selection")
            
            Spacer()
            
            Text("\(viewModel.userSelection.count)/\(viewModel.currentPattern?.sequenceLength ?? 0)")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(ColorScheme.textSecondary)
                .accessibilityLabel("Selected \(viewModel.userSelection.count) of \(viewModel.currentPattern?.sequenceLength ?? 0) colors")
        }
        .padding(.bottom, Constants.Layout.spacing)
    }
    
    // MARK: - Color Selection Grid
    
    private var colorSelectionGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: Constants.Layout.gameGridSpacing),
            GridItem(.flexible(), spacing: Constants.Layout.gameGridSpacing),
            GridItem(.flexible(), spacing: Constants.Layout.gameGridSpacing),
            GridItem(.flexible(), spacing: Constants.Layout.gameGridSpacing)
        ]
        
        return LazyVGrid(columns: columns, spacing: Constants.Layout.gameGridSpacing) {
            ForEach(viewModel.availableColors) { color in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        viewModel.selectColor(color)
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(color.color)
                                .frame(height: 70)
                            
                            Text(color.symbol)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(color.name == "White" ? ColorScheme.background : .white)
                            
                            Circle()
                                .stroke(ColorScheme.accentSecondary, lineWidth: 3)
                                .frame(height: 70)
                        }
                        .shadow(color: color.color.opacity(0.3), radius: 5, x: 0, y: 3)
                        
                        Text(color.name)
                            .font(.caption)
                            .foregroundColor(ColorScheme.textSecondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Select \(color.name) color")
                .accessibilityHint("Adds \(color.name) to your pattern")
            }
        }
    }
    
    // MARK: - Start/Restart Button
    
    private var startButton: some View {
        Button(action: {
            viewModel.startNewGame()
        }) {
            Text(viewModel.gameState == .ready ? "Start Game" : "Play Again")
                .font(.system(size: 20, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: Constants.Layout.buttonHeight)
                .foregroundColor(.white)
                .background(ColorScheme.buttonPrimary)
                .cornerRadius(Constants.Layout.cornerRadius)
        }
    }
    
    // MARK: - Game Over View
    
    private var gameOverView: some View {
        VStack(spacing: Constants.Layout.spacing * 2) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 80))
                .foregroundColor(ColorScheme.accentPrimary)
            
            Text("Game Over!")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(ColorScheme.textPrimary)
            
            VStack(spacing: 12) {
                ResultRow(label: "Final Score", value: "\(viewModel.score)")
                ResultRow(label: "Level Reached", value: "\(viewModel.level)")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(ColorScheme.buttonPrimary.opacity(0.2))
            )
        }
        .padding(.horizontal, Constants.Layout.padding)
    }
    
    // MARK: - Helpers
    
    private var stateTitle: String {
        switch viewModel.gameState {
        case .ready:
            return "Get Ready!"
        case .showing:
            return "Memorize This Pattern"
        case .memorizing:
            return "Remember..."
        case .playing:
            return "Recreate the Pattern"
        case .correct:
            return "Correct!"
        case .incorrect:
            return "Incorrect"
        case .gameOver:
            return "Game Over"
        }
    }
}

// MARK: - Supporting Views

struct InfoBadge: View {
    let icon: String
    let label: String
    let value: String
    var color: Color = ColorScheme.accentPrimary
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(ColorScheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

struct ResultRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(ColorScheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(ColorScheme.accentPrimary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(viewModel: GameViewModel())
    }
}

