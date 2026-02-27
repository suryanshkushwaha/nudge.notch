//
//  NudgeTypes.swift
//  NudgeNotch
//
//  Created with love for your wellbeing.
//

import Foundation

// MARK: - Notch State

enum NotchState {
    case closed
    case open
}

// MARK: - Blink Nudge

struct Nudge: Identifiable {
    let id = UUID()
    let message: String
}
