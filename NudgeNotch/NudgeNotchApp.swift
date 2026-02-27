//
//  NudgeNotchApp.swift
//  NudgeNotch
//
//  Your wellness companion that lives in the notch.
//  Reminds you to take breaks, drink water, and stay motivated.
//

import SwiftUI

@main
struct NudgeNotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu bar icon for quick access
        MenuBarExtra("NudgeNotch", systemImage: "leaf.fill") {
            Button("Open NudgeNotch") {
                withAnimation {
                    appDelegate.vm.open()
                }
            }
            .keyboardShortcut("N", modifiers: [.command, .shift])

            Divider()

            Button("Take a Break Now") {
                NudgeManager.shared.takeBreakNow()
            }

            Button("Drank Water") {
                NudgeManager.shared.acknowledgeWater()
            }

            Button("New Quote") {
                NudgeManager.shared.refreshQuote()
            }

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
