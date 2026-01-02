//
//  GameViewModel.swift
//  ColorQuest
//
//  ViewModel managing game state and logic
//

import SwiftUI
import Combine

enum GameState {
    case ready
    case showing
    case memorizing
    case playing
    case correct
    case incorrect
    case gameOver
}

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .ready
    @Published var currentPattern: ColorPattern?
    @Published var userSelection: [PatternColor] = []
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var lives: Int = Constants.Game.startingLives
    @Published var memoryTimeRemaining: TimeInterval = 0
    @Published var showingPattern: Bool = false
    @Published var availableColors: [PatternColor] = []
    @Published var feedbackMessage: String = ""
    
    @AppStorage(Constants.Storage.highestScore) private var highestScore: Int = 0
    @AppStorage(Constants.Storage.currentLevel) private var savedLevel: Int = 1
    @AppStorage(Constants.Storage.totalGamesPlayed) private var totalGamesPlayed: Int = 0
    @AppStorage(Constants.Storage.soundEnabled) private var soundEnabled: Bool = true
    @AppStorage(Constants.Storage.colorBlindMode) private var colorBlindMode: Bool = false
    
    private var memoryTimer: Timer?
    private var patternService = PatternGeneratorService.shared
    private var performanceHistory: [Double] = []
    
    init() {
        level = savedLevel
    }
    
    // MARK: - Game Flow
    
    func startNewGame() {
        score = 0
        level = 1
        lives = Constants.Game.startingLives
        performanceHistory = []
        totalGamesPlayed += 1
        gameState = .ready
        startNewRound()
    }
    
    func startNewRound() {
        userSelection = []
        feedbackMessage = ""
        
        let colorScheme: ColorSchemeType = colorBlindMode ? .colorBlind : .normal
        let performanceScore = calculateAveragePerformance()
        
        currentPattern = patternService.generatePattern(
            forLevel: level,
            colorScheme: colorScheme,
            performanceScore: performanceScore
        )
        
        availableColors = colorScheme.availableColors.shuffled()
        
        gameState = .showing
        showPattern()
    }
    
    private func showPattern() {
        showingPattern = true
        gameState = .memorizing
        
        // Start memory phase immediately
        startMemoryPhase()
    }
    
    private func startMemoryPhase() {
        guard let pattern = currentPattern else { return }
        
        let memoryTime = patternService.calculateMemoryTime(
            forDifficulty: pattern.difficulty,
            level: level
        )
        
        memoryTimeRemaining = memoryTime
        
        memoryTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.memoryTimeRemaining -= 0.1
            
            if self.memoryTimeRemaining <= 0 {
                timer.invalidate()
                self.transitionToPlaying()
            }
        }
    }
    
    private func transitionToPlaying() {
        showingPattern = false
        gameState = .playing
    }
    
    // MARK: - User Interaction
    
    func selectColor(_ color: PatternColor) {
        guard gameState == .playing else { return }
        guard let pattern = currentPattern else { return }
        
        userSelection.append(color)
        
        // Check if selection is complete
        if userSelection.count == pattern.sequenceLength {
            validateSelection()
        }
    }
    
    func removeLastSelection() {
        guard gameState == .playing, !userSelection.isEmpty else { return }
        userSelection.removeLast()
    }
    
    private func validateSelection() {
        guard let pattern = currentPattern else { return }
        
        let isCorrect = patternService.validateSelection(userSelection, against: pattern)
        
        if isCorrect {
            handleCorrectAnswer()
        } else {
            handleIncorrectAnswer()
        }
    }
    
    private func handleCorrectAnswer() {
        gameState = .correct
        
        let points = patternService.calculatePoints(
            forDifficulty: currentPattern!.difficulty,
            timeRemaining: memoryTimeRemaining,
            totalTime: patternService.calculateMemoryTime(
                forDifficulty: currentPattern!.difficulty,
                level: level
            )
        )
        
        score += points
        feedbackMessage = "Perfect! +\(points) points"
        
        // Track performance (1.0 = perfect)
        performanceHistory.append(1.0)
        
        // Update high score
        if score > highestScore {
            highestScore = score
        }
        
        // Level up
        level += 1
        savedLevel = level
        
        // Continue to next round
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.startNewRound()
        }
    }
    
    private func handleIncorrectAnswer() {
        gameState = .incorrect
        lives -= 1
        feedbackMessage = "Incorrect! \(lives) lives remaining"
        
        // Track performance (0.0 = failed)
        performanceHistory.append(0.0)
        
        if lives <= 0 {
            gameOver()
        } else {
            // Continue to next round
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.startNewRound()
            }
        }
    }
    
    private func gameOver() {
        gameState = .gameOver
        memoryTimer?.invalidate()
        feedbackMessage = "Game Over! Final Score: \(score)"
    }
    
    // MARK: - Helper Methods
    
    private func calculateAveragePerformance() -> Double {
        guard !performanceHistory.isEmpty else { return 0.5 }
        
        // Calculate average of last 5 rounds
        let recentHistory = Array(performanceHistory.suffix(5))
        let average = recentHistory.reduce(0, +) / Double(recentHistory.count)
        return average
    }
    
    func cleanup() {
        memoryTimer?.invalidate()
        memoryTimer = nil
        gameState = .ready
        userSelection = []
        feedbackMessage = ""
        showingPattern = false
    }
    
    deinit {
        cleanup()
    }
}

