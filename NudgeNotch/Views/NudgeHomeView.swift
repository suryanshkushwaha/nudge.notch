//
//  NudgeHomeView.swift
//  NudgeNotch
//
//  The expanded notch content showing quotes, timers, and action buttons.
//

import SwiftUI

struct NudgeHomeView: View {
    @EnvironmentObject var vm: NotchViewModel
    @ObservedObject var nudgeManager = NudgeManager.shared
    @ObservedObject var settings = SettingsManager.shared

    var body: some View {
        VStack(spacing: 10) {
            // Active nudge alert banner
            if let nudge = nudgeManager.activeNudge {
                nudgeBanner(nudge)
            }

            // Quote section
            if settings.quotesEnabled {
                quoteSection
            }

            // Timer cards row
            if settings.breakRemindersEnabled || settings.waterRemindersEnabled {
                timerCardsRow
            }

            // Empty state
            if !settings.breakRemindersEnabled && !settings.waterRemindersEnabled && !settings.quotesEnabled {
                emptyState
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Nudge Banner

    private func nudgeBanner(_ nudge: Nudge) -> some View {
        HStack(spacing: 10) {
            // Nudge icon with pulse
            ZStack {
                Circle()
                    .fill(nudge.type.color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: nudge.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(nudge.type.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(nudge.type.title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text(nudge.message)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                withAnimation(.spring(.bouncy(duration: 0.3))) {
                    if nudge.type == .breakReminder {
                        nudgeManager.acknowledgeBreak()
                    } else {
                        nudgeManager.acknowledgeWater()
                    }
                }
            } label: {
                Text("Done!")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(nudge.type.color.opacity(0.3))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(nudge.type.color.opacity(0.08))
                .strokeBorder(nudge.type.color.opacity(0.2), lineWidth: 1)
        )
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }

    // MARK: - Quote Section

    private var quoteSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 16))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text("\"\(nudgeManager.currentQuote.text)\"")
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("— \(nudgeManager.currentQuote.author)")
                    .font(.system(.caption2, design: .serif))
                    .foregroundStyle(.gray)
            }

            Spacer()

            Button {
                nudgeManager.refreshQuote()
            } label: {
                Image(systemName: "arrow.trianglehead.2.clockwise")
                    .font(.system(size: 11))
                    .foregroundStyle(.purple.opacity(0.7))
                    .frame(width: 26, height: 26)
                    .background(Color.purple.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.04))
        )
    }

    // MARK: - Timer Cards

    private var timerCardsRow: some View {
        HStack(spacing: 10) {
            if settings.breakRemindersEnabled {
                timerCard(
                    icon: "figure.walk",
                    title: "Break",
                    countdown: nudgeManager.breakTimeFormatted,
                    color: .green,
                    action: { nudgeManager.acknowledgeBreak() },
                    actionLabel: "Take Break"
                )
            }

            if settings.waterRemindersEnabled {
                timerCard(
                    icon: "drop.fill",
                    title: "Water",
                    countdown: nudgeManager.waterTimeFormatted,
                    color: .cyan,
                    action: { nudgeManager.acknowledgeWater() },
                    actionLabel: "Drank Water"
                )
            }
        }
    }

    private func timerCard(
        icon: String,
        title: String,
        countdown: String,
        color: Color,
        action: @escaping () -> Void,
        actionLabel: String
    ) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(color)

                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                Text(countdown)
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
            }

            Button(action: action) {
                Text(actionLabel)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(color.opacity(0.12))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.07))
                .strokeBorder(Color.white.opacity(0.04), lineWidth: 1)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundStyle(.green.opacity(0.5))

            Text("All nudges are off")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.gray)

            Text("Enable reminders in Settings")
                .font(.caption2)
                .foregroundStyle(.gray.opacity(0.6))
        }
        .frame(maxWidth: .infinity, minHeight: 60)
    }
}

// MARK: - Preview

#Preview {
    NudgeHomeView()
        .environmentObject(NotchViewModel())
        .frame(width: 540, height: 160)
        .background(.black)
        .preferredColorScheme(.dark)
}
