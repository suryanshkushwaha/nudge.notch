//
//  Sizing.swift
//  NudgeNotch
//
//  Size constants and helpers for the notch window.
//

import SwiftUI

enum NotchLayout {

    // MARK: - Animation

    static let animation: Animation = .spring(.bouncy(duration: 0.4))

    // MARK: - Timing

    /// Delay before hover triggers open (ms)
    static let hoverOpenDelay: UInt64 = 200
    /// Delay before hover-out starts closing (ms)
    static let hoverDismissDelay: UInt64 = 100
    /// Delay before auto-close after hover-out (ms)
    static let hoverCloseDelay: UInt64 = 800

    // MARK: - Window & Notch Sizes

    static let openSize: CGSize = .init(width: 480, height: 140)
    static let shadowPadding: CGFloat = 20
    static let windowSize: CGSize = .init(
        width: openSize.width + shadowPadding * 2,
        height: openSize.height + shadowPadding
    )

    // MARK: - Corner Radius Insets

    static let cornerRadius = (
        opened: (top: CGFloat(19), bottom: CGFloat(24)),
        closed: (top: CGFloat(6), bottom: CGFloat(14))
    )

    // MARK: - Closed Notch Size

    static func closedSize(for screen: NSScreen? = NSScreen.main) -> CGSize {
        guard let screen else {
            return CGSize(width: 220, height: 32)
        }

        var notchHeight: CGFloat = 32
        var notchWidth: CGFloat = 220

        if let topLeftPadding = screen.auxiliaryTopLeftArea?.width,
           let topRightPadding = screen.auxiliaryTopRightArea?.width {
            notchWidth = screen.frame.width - topLeftPadding - topRightPadding + 4
        }

        if screen.safeAreaInsets.top > 0 {
            notchHeight = screen.safeAreaInsets.top
        }

        return CGSize(width: notchWidth, height: notchHeight)
    }
}
