//
//  PatternGeneratorService.swift
//  ColorQuest
//
//  Service for generating color patterns with adaptive difficulty
//

import Foundation
import SwiftUI

class PatternGeneratorService {
    static let shared = PatternGeneratorService()
    
    private init() {}
    
    // Generate pattern based on current level and performance
    func generatePattern(
        forLevel level: Int,
        colorScheme: ColorSchemeType = .normal,
        performanceScore: Double = 0.5
    ) -> ColorPattern {
        let difficulty = calculateDifficulty(level: level, performanceScore: performanceScore)
        return ColorPattern(difficulty: difficulty, colorScheme: colorScheme)
    }
    
    // Adaptive difficulty calculation based on level and performance
    private func calculateDifficulty(level: Int, performanceScore: Double) -> ColorPattern.Difficulty {
        // Performance score: 0.0 (poor) to 1.0 (excellent)
        let adjustedLevel = Double(level) * performanceScore
        
        switch adjustedLevel {
        case 0..<3:
            return .easy
        case 3..<7:
            return .medium
        case 7..<12:
            return .hard
        default:
            return .expert
        }
    }
    
    // Calculate memory display time based on difficulty and level
    func calculateMemoryTime(forDifficulty difficulty: ColorPattern.Difficulty, level: Int) -> TimeInterval {
        let baseTime = Constants.Game.maxMemoryTime
        let difficultyModifier = Double(difficulty.rawValue) * 0.5
        let levelModifier = Double(level) * 0.1
        
        let calculatedTime = baseTime - difficultyModifier - levelModifier
        return max(calculatedTime, Constants.Game.minMemoryTime)
    }
    
    // Calculate points earned for completing a pattern
    func calculatePoints(
        forDifficulty difficulty: ColorPattern.Difficulty,
        timeRemaining: TimeInterval,
        totalTime: TimeInterval
    ) -> Int {
        let basePoints = Constants.Game.basePointsPerPattern * difficulty.rawValue
        let timeBonus = Int((timeRemaining / totalTime) * Double(basePoints) * Constants.Game.timeBonusMultiplier)
        return basePoints + timeBonus
    }
    
    // Validate if user's selection matches the pattern
    func validateSelection(_ selection: [PatternColor], against pattern: ColorPattern) -> Bool {
        guard selection.count == pattern.colors.count else {
            return false
        }
        
        for (index, patternColor) in pattern.colors.enumerated() {
            if selection[index].name != patternColor.name {
                return false
            }
        }
        
        return true
    }
}

