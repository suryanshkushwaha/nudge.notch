//
//  SettingsManager.swift
//  NudgeNotch
//
//  Persistent settings backed by UserDefaults.
//

import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    // MARK: - Timer Intervals (in minutes)

    @Published var breakIntervalMinutes: Double {
        didSet { UserDefaults.standard.set(breakIntervalMinutes, forKey: Keys.breakInterval) }
    }

    @Published var waterIntervalMinutes: Double {
        didSet { UserDefaults.standard.set(waterIntervalMinutes, forKey: Keys.waterInterval) }
    }

    // MARK: - Feature Toggles

    @Published var breakRemindersEnabled: Bool {
        didSet { UserDefaults.standard.set(breakRemindersEnabled, forKey: Keys.breakEnabled) }
    }

    @Published var waterRemindersEnabled: Bool {
        didSet { UserDefaults.standard.set(waterRemindersEnabled, forKey: Keys.waterEnabled) }
    }

    @Published var quotesEnabled: Bool {
        didSet { UserDefaults.standard.set(quotesEnabled, forKey: Keys.quotesEnabled) }
    }

    // MARK: - Behavior

    @Published var nudgeDurationSeconds: Double {
        didSet { UserDefaults.standard.set(nudgeDurationSeconds, forKey: Keys.nudgeDuration) }
    }

    @Published var openOnHover: Bool {
        didSet { UserDefaults.standard.set(openOnHover, forKey: Keys.openOnHover) }
    }

    // MARK: - Keys

    private enum Keys {
        static let breakInterval = "nudgeNotch.breakInterval"
        static let waterInterval = "nudgeNotch.waterInterval"
        static let breakEnabled = "nudgeNotch.breakEnabled"
        static let waterEnabled = "nudgeNotch.waterEnabled"
        static let quotesEnabled = "nudgeNotch.quotesEnabled"
        static let nudgeDuration = "nudgeNotch.nudgeDuration"
        static let openOnHover = "nudgeNotch.openOnHover"
    }

    // MARK: - Init

    private init() {
        let d = UserDefaults.standard

        breakIntervalMinutes = d.object(forKey: Keys.breakInterval) as? Double ?? 30
        waterIntervalMinutes = d.object(forKey: Keys.waterInterval) as? Double ?? 45
        breakRemindersEnabled = d.object(forKey: Keys.breakEnabled) as? Bool ?? true
        waterRemindersEnabled = d.object(forKey: Keys.waterEnabled) as? Bool ?? true
        quotesEnabled = d.object(forKey: Keys.quotesEnabled) as? Bool ?? true
        nudgeDurationSeconds = d.object(forKey: Keys.nudgeDuration) as? Double ?? 5
        openOnHover = d.object(forKey: Keys.openOnHover) as? Bool ?? true
    }
}
