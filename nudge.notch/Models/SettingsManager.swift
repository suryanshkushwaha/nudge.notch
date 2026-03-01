//
//  Settings.swift
//  NudgeNotch
//
//  UserDefaults keys and default values.
//

import Foundation

enum Settings {
    static let blinkIntervalKey = "nudgeNotch.blinkInterval"
    static let nudgeDurationKey = "nudgeNotch.nudgeDuration"
    static let openOnHoverKey = "nudgeNotch.openOnHover"
    
    static let lookAwayIntervalKey = "nudgeNotch.lookAwayInterval"
    static let lookAwayDurationKey = "nudgeNotch.lookAwayDuration"
    static let lookAwaySoundKey = "nudgeNotch.lookAwaySound"

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            blinkIntervalKey: 20.0,
            nudgeDurationKey: 3.0,
            openOnHoverKey: true,
            lookAwayIntervalKey: 1200.0,
            lookAwayDurationKey: 20.0,
            lookAwaySoundKey: true
        ])
    }
}
