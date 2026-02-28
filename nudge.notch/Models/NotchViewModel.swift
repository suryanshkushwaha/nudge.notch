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
    
    @Published var isHovering: Bool = false {
        didSet {
            if isHovering {
                cancelAutoClose()
            } else if notchState == .open && nudgeManager.activeNudge == nil {
                scheduleAutoClose(delay: Double(NotchLayout.hoverCloseDelay) / 1000.0)
            }
        }
    }

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
                if nudge != nil {
                    if self.notchState == .closed {
                        self.open()
                    }
                    self.cancelAutoClose()
                } else if self.notchState == .open && !self.isHovering {
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
    }

    // MARK: - Auto Close

    func cancelAutoClose() {
        autoCloseTask?.cancel()
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
