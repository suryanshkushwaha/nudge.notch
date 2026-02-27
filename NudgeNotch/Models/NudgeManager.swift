//
//  NudgeManager.swift
//  NudgeNotch
//
//  Manages blink reminders at a configurable interval.
//

import Foundation
import Combine

@MainActor
class NudgeManager: ObservableObject {
    static let shared = NudgeManager()

    // MARK: - Published State

    @Published var blinkCountdown: TimeInterval = 0
    @Published var activeNudge: Nudge?
    @Published var isRunning: Bool = false

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    private var nudgeDismissTask: Task<Void, Never>?

    // MARK: - Init

    private init() {
        resetBlinkTimer()
        start()
    }

    // MARK: - Timer Control

    func start() {
        guard !isRunning else { return }
        isRunning = true

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stop() {
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    // MARK: - Tick

    private func tick() {
        if blinkCountdown > 0 {
            blinkCountdown -= 1
        }
        if blinkCountdown <= 0 && activeNudge == nil {
            fireBlinkNudge()
        }
    }

    // MARK: - Nudge Triggers

    private func fireBlinkNudge() {
        let nudge = Nudge(message: "Blink now! Rest your eyes.")
        showNudge(nudge)
    }

    private func showNudge(_ nudge: Nudge) {
        activeNudge = nudge

        // Auto-dismiss after configured duration
        nudgeDismissTask?.cancel()
        nudgeDismissTask = Task {
            try? await Task.sleep(for: .seconds(UserDefaults.standard.double(forKey: Settings.nudgeDurationKey)))
            guard !Task.isCancelled else { return }
            dismissNudge()
        }
    }

    // MARK: - User Actions

    func dismissNudge() {
        nudgeDismissTask?.cancel()
        activeNudge = nil
        resetBlinkTimer()
    }

    // MARK: - Reset Timer

    func resetBlinkTimer() {
        blinkCountdown = UserDefaults.standard.double(forKey: Settings.blinkIntervalKey)
    }

    // MARK: - Formatted Countdown

    var blinkTimeFormatted: String {
        let totalSeconds = Int(max(0, blinkCountdown))
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
