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
