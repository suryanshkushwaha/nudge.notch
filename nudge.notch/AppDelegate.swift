//
//  AppDelegate.swift
//  NudgeNotch
//
//  Creates and manages the floating notch window.
//

import Cocoa
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    let vm = NotchViewModel()
    private var powerObserver: PowerStateObserver?

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        setupNotchWindow()

        // Ensure NudgeManager is initialized and running
        _ = NudgeManager.shared

        // Observe screen changes to reposition the window
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenConfigurationDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        // Pause / resume timers on sleep, screen off, and lock
        powerObserver = PowerStateObserver(
            onSleep: { NudgeManager.shared.stop() },
            onWake:  { NudgeManager.shared.start() }
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        NudgeManager.shared.stop()
    }

    // MARK: - Window Setup

    private func setupNotchWindow() {
        guard let screen = NSScreen.main else { return }

        let notchWindow = NudgeNotchWindow(
            contentRect: NSRect(
                x: 0, y: 0,
                width: NotchLayout.windowSize.width,
                height: NotchLayout.windowSize.height
            )
        )

        notchWindow.contentView = NSHostingView(
            rootView: ContentView()
                .environmentObject(vm)
                .environmentObject(NudgeManager.shared)
        )

        notchWindow.orderFrontRegardless()
        positionWindow(notchWindow, on: screen)

        self.window = notchWindow
    }

    // MARK: - Window Positioning

    private func positionWindow(_ window: NSWindow, on screen: NSScreen) {
        let screenFrame = screen.frame
        window.setFrameOrigin(
            NSPoint(
                x: screenFrame.origin.x + (screenFrame.width / 2) - window.frame.width / 2,
                y: screenFrame.origin.y + screenFrame.height - window.frame.height
            )
        )
    }

    @objc private func screenConfigurationDidChange() {
        guard let screen = NSScreen.main, let window else { return }
        positionWindow(window, on: screen)
    }
}
