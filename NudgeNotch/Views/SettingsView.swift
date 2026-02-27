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

    var body: some View {
        Form {
            // MARK: - Blink Reminder

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Remind every")
                        Spacer()
                        Text("\(Int(blinkInterval))s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $blinkInterval, in: 5...300, step: 5)
                        .onChange(of: blinkInterval) { _, _ in
                            nudgeManager.resetBlinkTimer()
                        }
                }
            } header: {
                Label("Blink Reminder", systemImage: "eye")
            } footer: {
                Text("Reminds you to blink and rest your eyes at regular intervals.")
            }

            // MARK: - Behavior

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Nudge popup duration")
                        Spacer()
                        Text("\(Int(nudgeDuration))s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $nudgeDuration, in: 2...10, step: 1)
                }

                Toggle("Open notch on hover", isOn: $openOnHover)
            } header: {
                Label("Behavior", systemImage: "hand.tap")
            } footer: {
                Text("Controls how the notch responds to interaction.")
            }

            // MARK: - About

            Section {
                HStack {
                    Text("NudgeNotch")
                        .fontWeight(.medium)
                    Spacer()
                    Text("v0.2.1")
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
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(NudgeManager.shared)
        .frame(width: 440, height: 400)
}
