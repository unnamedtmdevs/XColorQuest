//
//  ColorPattern.swift
//  ColorQuest
//
//  Model representing a color pattern puzzle
//

import SwiftUI

struct ColorPattern: Identifiable, Equatable {
    let id = UUID()
    let colors: [PatternColor]
    let difficulty: Difficulty
    let sequenceLength: Int
    
    enum Difficulty: Int, CaseIterable {
        case easy = 1
        case medium = 2
        case hard = 3
        case expert = 4
        
        var displayName: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .hard: return "Hard"
            case .expert: return "Expert"
            }
        }
        
        var sequenceLength: Int {
            switch self {
            case .easy: return 3
            case .medium: return 4
            case .hard: return 5
            case .expert: return 6
            }
        }
    }
    
    init(difficulty: Difficulty, colorScheme: ColorSchemeType = .normal) {
        self.difficulty = difficulty
        self.sequenceLength = difficulty.sequenceLength
        self.colors = PatternColor.generateSequence(
            length: sequenceLength,
            colorScheme: colorScheme
        )
    }
}

struct PatternColor: Identifiable, Equatable {
    let id = UUID()
    let color: Color
    let name: String
    let symbol: String
    
    static func generateSequence(length: Int, colorScheme: ColorSchemeType) -> [PatternColor] {
        var sequence: [PatternColor] = []
        let availableColors = colorScheme.availableColors
        
        for _ in 0..<length {
            if let randomColor = availableColors.randomElement() {
                sequence.append(randomColor)
            }
        }
        
        return sequence
    }
}

enum ColorSchemeType {
    case normal
    case colorBlind
    
    var availableColors: [PatternColor] {
        switch self {
        case .normal:
            return [
                PatternColor(color: ColorScheme.buttonPrimary, name: "Blue", symbol: "●"),
                PatternColor(color: Color(hex: "#10B981"), name: "Green", symbol: "■"),
                PatternColor(color: Color(hex: "#F59E0B"), name: "Orange", symbol: "▲"),
                PatternColor(color: ColorScheme.accentSecondary, name: "White", symbol: "◆"),
                PatternColor(color: Color(hex: "#EF4444"), name: "Red", symbol: "★"),
                PatternColor(color: Color(hex: "#FBBF24"), name: "Yellow", symbol: "✦"),
                PatternColor(color: Color(hex: "#8B5CF6"), name: "Purple", symbol: "◉"),
                PatternColor(color: Color(hex: "#EC4899"), name: "Pink", symbol: "♦")
            ]
        case .colorBlind:
            // Using symbols and high-contrast colors for color blind mode
            return [
                PatternColor(color: Color(hex: "#0173B2"), name: "Blue", symbol: "●"),
                PatternColor(color: Color(hex: "#DE8F05"), name: "Orange", symbol: "■"),
                PatternColor(color: Color(hex: "#029E73"), name: "Teal", symbol: "▲"),
                PatternColor(color: Color(hex: "#CC78BC"), name: "Magenta", symbol: "◆"),
                PatternColor(color: Color(hex: "#ECE133"), name: "Yellow", symbol: "★"),
                PatternColor(color: Color(hex: "#56B4E9"), name: "Sky", symbol: "✦"),
                PatternColor(color: Color(hex: "#F0E442"), name: "Lime", symbol: "◉"),
                PatternColor(color: Color(hex: "#D55E00"), name: "Vermillion", symbol: "♦")
            ]
        }
    }
}

