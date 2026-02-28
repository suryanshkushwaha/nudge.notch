//
//  NudgeHomeView.swift
//  NudgeNotch
//
//  The expanded notch content showing the blink reminder.
//

import SwiftUI

struct NudgeHomeView: View {
    @EnvironmentObject var vm: NotchViewModel
    @EnvironmentObject var nudgeManager: NudgeManager

    var body: some View {
        Group {
            if nudgeManager.mode == .blink {
                VStack(spacing: 10) {
                    BlinkingEyeView(eyeWidth: 56)

                    Text("BLINK")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .tracking(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.top, 4)
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("LOOK AWAY")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text("at least 20 feet")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text(nudgeManager.activeNudgeTimeFormatted)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .frame(minWidth: 50, alignment: .trailing)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NudgeHomeView()
        .environmentObject(NotchViewModel())
        .environmentObject(NudgeManager.shared)
        .frame(width: 540, height: 160)
        .background(.black)
        .preferredColorScheme(.dark)
}
