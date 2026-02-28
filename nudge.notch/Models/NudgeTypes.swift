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

enum NudgeMode {
    case blink
    case lookAway
}

// MARK: - Blink Nudge

struct Nudge: Identifiable, Equatable {
    let id = UUID()
    var duration: TimeInterval? = nil
}
