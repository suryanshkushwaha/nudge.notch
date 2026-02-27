//
//  NotchViewModel.swift
//  NudgeNotch
//
//  Main view model managing notch state, sizing, and nudge reactions.
//

import SwiftUI
import Combine

class NotchViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var notchState: NotchState = .closed
    @Published var notchSize: CGSize = getClosedNotchSize()
    @Published var closedNotchSize: CGSize = getClosedNotchSize()
    @Published var openedByNudge: Bool = false

    // MARK: - Dependencies

    let nudgeManager = NudgeManager.shared
    let settings = SettingsManager.shared

    // MARK: - Animation

    let animation: Animation = .spring(.bouncy(duration: 0.4))

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()
    private var autoCloseTask: Task<Void, Never>?

    // MARK: - Init

    init() {
        // React to nudges: auto-open when a nudge fires
        nudgeManager.$activeNudge
            .receive(on: RunLoop.main)
            .sink { [weak self] nudge in
                guard let self else { return }
                if nudge != nil && self.notchState == .closed {
                    withAnimation(self.animation) {
                        self.open()
                    }
                    self.openedByNudge = true
                    self.scheduleAutoClose(delay: self.settings.nudgeDurationSeconds + 2)
                } else if nudge == nil && self.openedByNudge && self.notchState == .open {
                    self.scheduleAutoClose(delay: 1.5)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Open / Close

    func open() {
        autoCloseTask?.cancel()
        notchSize = openNotchSize
        notchState = .open
    }

    func close() {
        autoCloseTask?.cancel()
        notchSize = getClosedNotchSize()
        closedNotchSize = notchSize
        notchState = .closed
        openedByNudge = false
    }

    func toggle() {
        if notchState == .open {
            close()
        } else {
            open()
        }
    }

    // MARK: - Auto Close

    func cancelAutoClose() {
        autoCloseTask?.cancel()
        openedByNudge = false
    }

    private func scheduleAutoClose(delay: TimeInterval = 3) {
        autoCloseTask?.cancel()
        autoCloseTask = Task {
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            withAnimation(animation) {
                close()
            }
        }
    }

    // MARK: - Computed

    var effectiveClosedNotchHeight: CGFloat {
        closedNotchSize.height
    }
}
