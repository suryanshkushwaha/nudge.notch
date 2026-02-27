//
//  SettingsView.swift
//  NudgeNotch
//
//  Settings panel for configuring the blink reminder.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(Settings.blinkIntervalKey) private var blinkInterval: Double = 20
    @AppStorage(Settings.nudgeDurationKey) private var nudgeDuration: Double = 3
    @AppStorage(Settings.openOnHoverKey) private var openOnHover = true
    @EnvironmentObject var nudgeManager: NudgeManager

    /// Common interval presets (label, seconds)
    private let intervalPresets: [(String, Double)] = [
        ("10s", 10), ("20s", 20), ("30s", 30),
        ("1m", 60), ("2m", 120), ("5m", 300), ("10m", 600),
    ]

    /// Nudge duration presets
    private let durationPresets: [Double] = [2, 3, 5, 8]

    var body: some View {
        Form {
            // MARK: - Blink Reminder

            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Remind me to blink every")
                        .font(.subheadline)

                    HStack(spacing: 6) {
                        ForEach(intervalPresets, id: \.1) { label, seconds in
                            chipButton(label, isSelected: blinkInterval == seconds) {
                                blinkInterval = seconds
                                nudgeManager.resetBlinkTimer()
                            }
                        }
                    }

                    if !intervalPresets.contains(where: { $0.1 == blinkInterval }) {
                        Text("Custom: \(formattedInterval(blinkInterval))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 2)
            } header: {
                Label("Blink Reminder", systemImage: "eye")
            } footer: {
                Text("Regular blink reminders reduce eye strain during screen time.")
            }

            // MARK: - Behavior

            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Show nudge for")
                        .font(.subheadline)

                    HStack(spacing: 6) {
                        ForEach(durationPresets, id: \.self) { duration in
                            chipButton("\(Int(duration))s", isSelected: nudgeDuration == duration) {
                                nudgeDuration = duration
                            }
                        }
                    }
                }
                .padding(.vertical, 2)

                Toggle("Open notch on hover", isOn: $openOnHover)
            } header: {
                Label("Behavior", systemImage: "hand.tap")
            }

            // MARK: - About

            Section {
                HStack {
                    Text("NudgeNotch")
                        .fontWeight(.medium)
                    Spacer()
                    Text("v0.2.3")
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Your blink reminder that lives in the notch.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("Blink. Rest your eyes. Stay focused.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            } header: {
                Label("About", systemImage: "info.circle")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 440, minHeight: 380)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Quit app", role: .destructive) {
                    NSApplication.shared.terminate(nil)
                }
                .controlSize(.large)
            }
        }
    }

    // MARK: - Helpers

    private func formattedInterval(_ seconds: Double) -> String {
        let s = Int(seconds)
        if s < 60 { return "\(s)s" }
        let m = s / 60
        let rem = s % 60
        return rem > 0 ? "\(m)m \(rem)s" : "\(m)m"
    }

    private func chipButton(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .monospacedDigit()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? Color.accentColor : Color.primary.opacity(0.06))
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(NudgeManager.shared)
        .frame(width: 440, height: 400)
}
