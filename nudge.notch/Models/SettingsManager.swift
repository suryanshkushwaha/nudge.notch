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

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            blinkIntervalKey: 20.0,
            nudgeDurationKey: 3.0,
            openOnHoverKey: true,
        ])
    }
}
