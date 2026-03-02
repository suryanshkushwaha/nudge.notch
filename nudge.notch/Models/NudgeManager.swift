//
//  NudgeManager.swift
//  NudgeNotch
//
//  Manages blink reminders at a configurable interval.
//

import Foundation
import Combine
import AudioToolbox

@MainActor
class NudgeManager: ObservableObject {
    static let shared = NudgeManager()

    // MARK: - Published State

    @Published var mode: NudgeMode = .blink
    @Published var blinkCountdown: TimeInterval = 0
    @Published var lookAwayCountdown: TimeInterval = 0
    @Published var activeNudgeCountdown: TimeInterval = 0
    @Published var activeNudge: Nudge?
    @Published var isRunning: Bool = false

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?

    // MARK: - Init

    private init() {
        resetBlinkTimer()
        resetLookAwayTimer()
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
        // Look Away timer should never pause, even during blink nudges
        if lookAwayCountdown > 0 {
            lookAwayCountdown -= 1
        }

        if activeNudge != nil {
            if activeNudgeCountdown > 0 {
                activeNudgeCountdown -= 1
            }
            if activeNudgeCountdown <= 0 {
                dismissNudge()
            }
        } else {
            // Check for Look Away trigger first (higher priority)
            if lookAwayCountdown <= 0 {
                fireLookAwayNudge()
                return
            }

            // Handle blink countdown
            if mode == .blink {
                if blinkCountdown > 0 {
                    blinkCountdown -= 1
                }
                if blinkCountdown <= 0 {
                    fireBlinkNudge()
                }
            }
        }
    }

    // MARK: - Nudge Triggers

    private func fireBlinkNudge() {
        let nudge = Nudge(duration: UserDefaults.standard.double(forKey: Settings.nudgeDurationKey))
        showNudge(nudge)
    }
    
    private func fireLookAwayNudge() {
        mode = .lookAway
        let duration = UserDefaults.standard.double(forKey: Settings.lookAwayDurationKey)
        let nudge = Nudge(duration: duration)
        showNudge(nudge)
    }

    private func showNudge(_ nudge: Nudge) {
        activeNudge = nudge
        activeNudgeCountdown = nudge.duration ?? UserDefaults.standard.double(forKey: Settings.nudgeDurationKey)
    }

    // MARK: - User Actions

    func dismissNudge() {
        let wasLookAway = mode == .lookAway
        activeNudge = nil
        
        if wasLookAway {
            playLookAwayEndSound()
            mode = .blink
            resetLookAwayTimer()
        } else {
            resetBlinkTimer()
        }
    }

    // MARK: - Sound

    private var lookAwayEndSoundID: SystemSoundID = 0

    private func loadLookAwayEndSound() {
        guard lookAwayEndSoundID == 0 else { return }
        let url = URL(fileURLWithPath: "/System/Library/Sounds/Glass.aiff")
        let status = AudioServicesCreateSystemSoundID(url as CFURL, &lookAwayEndSoundID)
        if status != noErr {
            print("[NudgeManager] Failed to load Glass.aiff (OSStatus \(status))")
            lookAwayEndSoundID = 0
        }
    }

    private func playLookAwayEndSound() {
        guard UserDefaults.standard.bool(forKey: Settings.lookAwaySoundKey) else { return }
        loadLookAwayEndSound()
        guard lookAwayEndSoundID != 0 else { return }
        AudioServicesPlaySystemSound(lookAwayEndSoundID)
    }

    // MARK: - Reset Timer

    func resetBlinkTimer() {
        blinkCountdown = UserDefaults.standard.double(forKey: Settings.blinkIntervalKey)
    }
    
    func resetLookAwayTimer() {
        lookAwayCountdown = UserDefaults.standard.double(forKey: Settings.lookAwayIntervalKey)
    }

    // MARK: - Formatted Countdown

    var blinkTimeFormatted: String {
        let totalSeconds = Int(max(0, blinkCountdown))
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    var activeNudgeTimeFormatted: String {
        let totalSeconds = Int(max(0, activeNudgeCountdown))
        return String(totalSeconds)
    }
}
