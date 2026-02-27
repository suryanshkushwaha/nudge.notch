//
//  EyeViews.swift
//  NudgeNotch
//
//  Eye components: animated blinking eye, static eye icon, and shared outline shape.
//  Inspired by Daniel Bruce's SVG eye icon and Federico Brigante's blink animation.
//

import SwiftUI

// MARK: - Eye Outline Shape

/// Almond-shaped eye outline derived from the SVG path data.
struct EyeOutlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()

        // Start at left corner (mid-height)
        path.move(to: CGPoint(x: 0, y: h * 0.5))

        // Lower-left → bottom-center
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: 0, y: h * 0.569),
            control2: CGPoint(x: w * 0.172, y: h)
        )

        // Bottom-center → right corner
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.5),
            control1: CGPoint(x: w * 0.828, y: h),
            control2: CGPoint(x: w, y: h * 0.569)
        )

        // Right corner → top-center
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: w, y: h * 0.431),
            control2: CGPoint(x: w * 0.828, y: 0)
        )

        // Top-center → left corner
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.5),
            control1: CGPoint(x: w * 0.172, y: 0),
            control2: CGPoint(x: 0, y: h * 0.431)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Blinking Eye View

struct BlinkingEyeView: View {
    var eyeWidth: CGFloat = 64

    @State private var lidClose: CGFloat = 0
    @State private var blinkTask: Task<Void, Never>?

    private var eyeHeight: CGFloat { eyeWidth * 0.61 }

    var body: some View {
        ZStack {
            ZStack {
                EyeOutlineShape()
                    .fill(.white)

                Circle()
                    .fill(.black)
                    .frame(width: eyeHeight * 0.65, height: eyeHeight * 0.65)

                Circle()
                    .fill(.white)
                    .frame(width: eyeHeight * 0.65 * 0.32, height: eyeHeight * 0.65 * 0.32)
                    .offset(
                        x: eyeHeight * 0.65 * 0.12,
                        y: -eyeHeight * 0.65 * 0.1
                    )
            }
            .clipShape(EyeOutlineShape())
            .scaleEffect(y: 1.0 - lidClose, anchor: .center)

            EyeOutlineShape()
                .stroke(.white, lineWidth: lidClose > 0.8 ? 2.5 : 2)
                .scaleEffect(y: 1.0 - lidClose, anchor: .center)
        }
        .frame(width: eyeWidth, height: eyeHeight)
        .scaleEffect(y: 1.0 - (lidClose * 0.15), anchor: .center)
        .offset(y: lidClose * 2)
        .onAppear { startBlinkLoop() }
        .onDisappear { blinkTask?.cancel() }
    }

    private func startBlinkLoop() {
        blinkTask?.cancel()
        blinkTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.6))

            while !Task.isCancelled {
                withAnimation(.easeIn(duration: 0.08)) {
                    lidClose = 1.0
                }
                try? await Task.sleep(for: .milliseconds(130))

                withAnimation(.easeOut(duration: 0.22)) {
                    lidClose = 0
                }
                try? await Task.sleep(for: .milliseconds(300))
                try? await Task.sleep(for: .seconds(2.0))
            }
        }
    }
}

// MARK: - Static Eye Icon

/// A small, non-animated open eye icon reusing the same outline shape.
struct StaticEyeIcon: View {
    var width: CGFloat = 14
    var color: Color = .white

    private var height: CGFloat { width * 0.61 }

    var body: some View {
        ZStack {
            EyeOutlineShape()
                .fill(color)

            Circle()
                .fill(.black)
                .frame(width: height * 0.65, height: height * 0.65)

            Circle()
                .fill(color)
                .frame(width: height * 0.65 * 0.32, height: height * 0.65 * 0.32)
                .offset(
                    x: height * 0.65 * 0.12,
                    y: -height * 0.65 * 0.1
                )
        }
        .clipShape(EyeOutlineShape())
        .overlay {
            EyeOutlineShape()
                .stroke(color, lineWidth: 1.5)
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Preview

#Preview {
    BlinkingEyeView(eyeWidth: 80)
        .padding(40)
        .background(.black)
        .preferredColorScheme(.dark)
}
