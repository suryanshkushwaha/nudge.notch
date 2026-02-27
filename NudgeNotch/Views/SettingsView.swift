//
//  SettingsView.swift
//  NudgeNotch
//
//  Settings panel for configuring reminders and behavior.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    @ObservedObject var nudgeManager = NudgeManager.shared

    var body: some View {
        Form {
            // MARK: - Break Reminders

            Section {
                Toggle("Enable break reminders", isOn: $settings.breakRemindersEnabled)

                if settings.breakRemindersEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Remind every")
                            Spacer()
                            Text("\(Int(settings.breakIntervalMinutes)) min")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Slider(value: $settings.breakIntervalMinutes, in: 5...120, step: 5)
                            .onChange(of: settings.breakIntervalMinutes) { _, _ in
                                nudgeManager.resetBreakTimer()
                            }
                    }
                }
            } header: {
                Label("Break Reminders", systemImage: "figure.walk")
            } footer: {
                Text("Reminds you to stand up, stretch, and take a short break.")
            }

            // MARK: - Water Reminders

            Section {
                Toggle("Enable water reminders", isOn: $settings.waterRemindersEnabled)

                if settings.waterRemindersEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Remind every")
                            Spacer()
                            Text("\(Int(settings.waterIntervalMinutes)) min")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Slider(value: $settings.waterIntervalMinutes, in: 5...120, step: 5)
                            .onChange(of: settings.waterIntervalMinutes) { _, _ in
                                nudgeManager.resetWaterTimer()
                            }
                    }
                }
            } header: {
                Label("Water Reminders", systemImage: "drop.fill")
            } footer: {
                Text("Reminds you to stay hydrated throughout the day.")
            }

            // MARK: - Motivation

            Section {
                Toggle("Show motivational quotes", isOn: $settings.quotesEnabled)
            } header: {
                Label("Motivation", systemImage: "sparkles")
            } footer: {
                Text("Displays wellness quotes to keep you inspired.")
            }

            // MARK: - Behavior

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Nudge popup duration")
                        Spacer()
                        Text("\(Int(settings.nudgeDurationSeconds))s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $settings.nudgeDurationSeconds, in: 3...15, step: 1)
                }

                Toggle("Open notch on hover", isOn: $settings.openOnHover)
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
                    Text("v0.1.0")
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Your wellness companion that lives in the notch.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("Take breaks. Drink water. Stay motivated.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            } header: {
                Label("About", systemImage: "info.circle")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 440, minHeight: 520)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Quit NudgeNotch", role: .destructive) {
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
        .frame(width: 440, height: 580)
}
