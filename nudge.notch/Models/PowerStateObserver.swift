//
//  PowerStateObserver.swift
//  NudgeNotch
//
//  Pauses and resumes NudgeManager when the Mac sleeps, wakes,
//  the screen turns off/on, or the session is locked/unlocked.
//

import Cocoa

final class PowerStateObserver {

    private let onSleep: () -> Void
    private let onWake: () -> Void

    // MARK: - Init

    /// - Parameters:
    ///   - onSleep: Called when the system should be considered inactive (sleep / screen off / lock).
    ///   - onWake:  Called when the system should be considered active (wake / screen on / unlock).
    init(onSleep: @escaping () -> Void, onWake: @escaping () -> Void) {
        self.onSleep = onSleep
        self.onWake = onWake
        registerObservers()
    }

    // MARK: - Registration

    private func registerObservers() {
        let wsnc = NSWorkspace.shared.notificationCenter

        // System sleep / wake
        wsnc.addObserver(self, selector: #selector(handleSleep),
                         name: NSWorkspace.willSleepNotification, object: nil)
        wsnc.addObserver(self, selector: #selector(handleWake),
                         name: NSWorkspace.didWakeNotification, object: nil)

        // Screen sleep / wake
        wsnc.addObserver(self, selector: #selector(handleSleep),
                         name: NSWorkspace.screensDidSleepNotification, object: nil)
        wsnc.addObserver(self, selector: #selector(handleWake),
                         name: NSWorkspace.screensDidWakeNotification, object: nil)

        // Lock / Unlock
        let dnc = DistributedNotificationCenter.default()
        dnc.addObserver(self, selector: #selector(handleSleep),
                        name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)
        dnc.addObserver(self, selector: #selector(handleWake),
                        name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil)
    }

    // MARK: - Handlers

    @objc private func handleSleep() {
        DispatchQueue.main.async { [weak self] in
            self?.onSleep()
        }
    }

    @objc private func handleWake() {
        DispatchQueue.main.async { [weak self] in
            self?.onWake()
        }
    }

    // MARK: - Teardown

    func removeObservers() {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        DistributedNotificationCenter.default().removeObserver(self)
    }

    deinit {
        removeObservers()
    }
}
