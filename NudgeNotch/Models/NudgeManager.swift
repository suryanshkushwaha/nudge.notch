//
//  NudgeManager.swift
//  NudgeNotch
//
//  Manages break reminders, water reminders, and motivational quotes.
//

import SwiftUI
import Combine

class NudgeManager: ObservableObject {
    static let shared = NudgeManager()

    // MARK: - Published State

    @Published var breakCountdown: TimeInterval = 0
    @Published var waterCountdown: TimeInterval = 0
    @Published var currentQuote: Quote
    @Published var activeNudge: Nudge?
    @Published var isRunning: Bool = false

    // MARK: - Dependencies

    private let settings = SettingsManager.shared
    private let quoteProvider = QuoteProvider.shared
    private var cancellables = Set<AnyCancellable>()
    private var nudgeDismissTask: Task<Void, Never>?

    // MARK: - Init

    private init() {
        currentQuote = quoteProvider.randomQuote()
        resetBreakTimer()
        resetWaterTimer()
        start()
    }

    // MARK: - Timer Control

    func start() {
        guard !isRunning else { return }
        isRunning = true

        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
            .store(in: &cancellables)
    }

    func stop() {
        isRunning = false
        cancellables.removeAll()
    }

    // MARK: - Tick

    private func tick() {
        if settings.breakRemindersEnabled {
            if breakCountdown > 0 {
                breakCountdown -= 1
            }
            if breakCountdown <= 0 && activeNudge == nil {
                fireBreakNudge()
            }
        }

        if settings.waterRemindersEnabled {
            if waterCountdown > 0 {
                waterCountdown -= 1
            }
            if waterCountdown <= 0 && activeNudge == nil {
                fireWaterNudge()
            }
        }
    }

    // MARK: - Nudge Triggers

    private func fireBreakNudge() {
        if settings.quotesEnabled {
            currentQuote = quoteProvider.nextQuote()
        }

        let nudge = Nudge(
            type: .breakReminder,
            message: "You've been working for \(Int(settings.breakIntervalMinutes)) min. Time to stretch and move!"
        )
        showNudge(nudge)
    }

    private func fireWaterNudge() {
        let nudge = Nudge(
            type: .waterReminder,
            message: "Stay hydrated! Take a sip of water right now."
        )
        showNudge(nudge)
    }

    private func showNudge(_ nudge: Nudge) {
        withAnimation(.spring(.bouncy(duration: 0.4))) {
            activeNudge = nudge
        }

        // Auto-dismiss after configured duration
        nudgeDismissTask?.cancel()
        nudgeDismissTask = Task {
            try? await Task.sleep(for: .seconds(settings.nudgeDurationSeconds))
            guard !Task.isCancelled else { return }
            dismissNudge()
        }
    }

    // MARK: - User Actions

    func dismissNudge() {
        nudgeDismissTask?.cancel()
        withAnimation(.spring(.bouncy(duration: 0.4))) {
            activeNudge = nil
        }
    }

    func acknowledgeBreak() {
        dismissNudge()
        resetBreakTimer()
    }

    func acknowledgeWater() {
        dismissNudge()
        resetWaterTimer()
    }

    func takeBreakNow() {
        fireBreakNudge()
    }

    func refreshQuote() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentQuote = quoteProvider.nextQuote()
        }
    }

    // MARK: - Reset Timers

    func resetBreakTimer() {
        breakCountdown = settings.breakIntervalMinutes * 60
    }

    func resetWaterTimer() {
        waterCountdown = settings.waterIntervalMinutes * 60
    }

    // MARK: - Formatted Countdowns

    var breakTimeFormatted: String {
        formatCountdown(breakCountdown)
    }

    var waterTimeFormatted: String {
        formatCountdown(waterCountdown)
    }

    private func formatCountdown(_ seconds: TimeInterval) -> String {
        let mins = Int(max(0, seconds)) / 60
        let secs = Int(max(0, seconds)) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    // MARK: - Next Upcoming

    var nextUpcomingNudgeType: NudgeType? {
        guard settings.breakRemindersEnabled || settings.waterRemindersEnabled else { return nil }

        if settings.breakRemindersEnabled && settings.waterRemindersEnabled {
            return breakCountdown <= waterCountdown ? .breakReminder : .waterReminder
        } else if settings.breakRemindersEnabled {
            return .breakReminder
        } else {
            return .waterReminder
        }
    }

    var nextUpcomingCountdown: String {
        guard let type = nextUpcomingNudgeType else { return "" }
        switch type {
        case .breakReminder: return breakTimeFormatted
        case .waterReminder: return waterTimeFormatted
        case .motivationalQuote: return ""
        }
    }
}
