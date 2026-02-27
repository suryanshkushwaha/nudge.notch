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
        // Menu bar icon for quick access
        MenuBarExtra("NudgeNotch", systemImage: "eye") {
            Button("Open NudgeNotch") {
                withAnimation {
                    appDelegate.vm.open()
                }
            }
            .keyboardShortcut("N", modifiers: [.command, .shift])

            Divider()

            Button("Settings…") {
                SettingsWindowController.shared.showWindow()
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            Button("Quit NudgeNotch") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("Q", modifiers: .command)
        }
    }
}
