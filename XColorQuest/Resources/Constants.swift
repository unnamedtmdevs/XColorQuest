//
//  Constants.swift
//  ColorQuest
//
//  App-wide constants and configuration
//

import Foundation
import SwiftUI

struct Constants {
    // App Storage Keys
    struct Storage {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let currentLevel = "currentLevel"
        static let highestScore = "highestScore"
        static let soundEnabled = "soundEnabled"
        static let colorBlindMode = "colorBlindMode"
        static let totalGamesPlayed = "totalGamesPlayed"
    }
    
    // Game Configuration
    struct Game {
        static let startingLives = 3
        static let basePointsPerPattern = 100
        static let timeBonusMultiplier = 1.5
        static let maxMemoryTime: TimeInterval = 8.0
        static let minMemoryTime: TimeInterval = 3.0
        static let patternDisplayDuration: TimeInterval = 0.8
    }
    
    // Animation Configuration
    struct Animation {
        static let buttonBounce = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
        static let fadeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slideIn = SwiftUI.Animation.easeOut(duration: 0.4)
        static let patternFlash = SwiftUI.Animation.easeInOut(duration: 0.5)
    }
    
    // Layout Configuration
    struct Layout {
        static let cornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 56
        static let spacing: CGFloat = 16
        static let padding: CGFloat = 20
        static let patternCircleSize: CGFloat = 60
        static let gameGridSpacing: CGFloat = 12
    }
    
    // Accessibility
    struct Accessibility {
        static let minimumTapTargetSize: CGFloat = 44
        static let largeTapTargetSize: CGFloat = 60
    }
    
    // Privacy Notice
    static let privacyNotice = """
    ColorQuest Privacy Notice:
    
    This app stores your game progress locally on your device using @AppStorage. No personal data is collected, transmitted, or shared with third parties. All game data remains on your device and can be reset at any time through the Settings menu.
    
    Data stored includes:
    • Game progress and scores
    • Settings preferences (sound, color blind mode)
    • Onboarding completion status
    
    You maintain full control over your data and can delete it anytime by resetting game progress in Settings.
    """
}

