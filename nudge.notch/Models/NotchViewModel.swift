//
//  NotchViewModel.swift
//  NudgeNotch
//
//  Main view model managing notch state, sizing, and nudge reactions.
//

import Cocoa
import Combine

@MainActor
class NotchViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var notchState: NotchState = .closed
    @Published var notchSize: CGSize = NotchLayout.closedSize()
    @Published var closedNotchSize: CGSize = NotchLayout.closedSize()
    @Published var openedByNudge: Bool = false

    // MARK: - Dependencies

    let nudgeManager = NudgeManager.shared

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()
    private var autoCloseTask: Task<Void, Never>?

    // MARK: - Init

    init() {
        // Cache closed size once; update only on screen change
        closedNotchSize = NotchLayout.closedSize()
        notchSize = closedNotchSize

        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.closedNotchSize = NotchLayout.closedSize()
                if self.notchState == .closed {
                    self.notchSize = self.closedNotchSize
                }
            }
            .store(in: &cancellables)

        // React to nudges: auto-open when a nudge fires
        nudgeManager.$activeNudge
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nudge in
                guard let self else { return }
                if nudge != nil && self.notchState == .closed {
                    self.open()
                    self.openedByNudge = true
                    self.scheduleAutoClose(delay: UserDefaults.standard.double(forKey: Settings.nudgeDurationKey) + 0.5)
                } else if nudge == nil && self.openedByNudge && self.notchState == .open {
                    self.scheduleAutoClose(delay: 0.3)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Open / Close

    func open() {
        autoCloseTask?.cancel()
        notchSize = NotchLayout.openSize
        notchState = .open
    }

    func close() {
        autoCloseTask?.cancel()
        notchSize = closedNotchSize
        notchState = .closed
        openedByNudge = false
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
            close()
        }
    }

}
