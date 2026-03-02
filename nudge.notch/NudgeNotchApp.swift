//
//  NudgeNotchApp.swift
//  NudgeNotch
//
//  Your blink reminder that lives in the notch.
//

import SwiftUI

@main
struct NudgeNotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        Settings.registerDefaults()
    }

    var body: some Scene {
        // No visible scene — the app runs as an accessory with only the notch window.
        // Use the notch's context menu (right-click) for Settings and Quit.
        SwiftUI.Settings {
            EmptyView()
        }
    }
}
