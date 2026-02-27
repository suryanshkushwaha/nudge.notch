//
//  Sizing.swift
//  NudgeNotch
//
//  Size constants and helpers for the notch window.
//

import SwiftUI

// MARK: - Window & Notch Sizes

let openNotchSize: CGSize = .init(width: 580, height: 180)
let shadowPadding: CGFloat = 20
let nudgeNotchWindowSize: CGSize = .init(
    width: openNotchSize.width + shadowPadding * 2,
    height: openNotchSize.height + shadowPadding
)

// MARK: - Corner Radius Insets

let cornerRadiusInsets = (
    opened: (top: CGFloat(19), bottom: CGFloat(24)),
    closed: (top: CGFloat(6), bottom: CGFloat(14))
)

// MARK: - Closed Notch Size

func getClosedNotchSize() -> CGSize {
    guard let screen = NSScreen.main else {
        return CGSize(width: 220, height: 32)
    }

    var notchHeight: CGFloat = 32
    var notchWidth: CGFloat = 220

    // Use auxiliary areas for exact notch width (like boring.notch)
    if let topLeftPadding = screen.auxiliaryTopLeftArea?.width,
       let topRightPadding = screen.auxiliaryTopRightArea?.width {
        notchWidth = screen.frame.width - topLeftPadding - topRightPadding + 4
    }

    if screen.safeAreaInsets.top > 0 {
        notchHeight = screen.safeAreaInsets.top
    }

    return CGSize(width: notchWidth, height: notchHeight)
}
