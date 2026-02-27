//
//  NudgeTypes.swift
//  NudgeNotch
//
//  Created with love for your wellbeing.
//

import SwiftUI

// MARK: - Notch State

enum NotchState {
    case closed
    case open
}

// MARK: - Nudge Type

enum NudgeType: String, CaseIterable, Identifiable {
    case breakReminder = "Break"
    case waterReminder = "Water"
    case motivationalQuote = "Quote"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .breakReminder: "figure.walk"
        case .waterReminder: "drop.fill"
        case .motivationalQuote: "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .breakReminder: .green
        case .waterReminder: .cyan
        case .motivationalQuote: .purple
        }
    }

    var title: String {
        switch self {
        case .breakReminder: "Time for a Break!"
        case .waterReminder: "Stay Hydrated!"
        case .motivationalQuote: "Daily Inspiration"
        }
    }
}

// MARK: - Nudge

struct Nudge: Identifiable {
    let id = UUID()
    let type: NudgeType
    let message: String
    let timestamp = Date()
}
