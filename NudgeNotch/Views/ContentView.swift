//
//  ContentView.swift
//  NudgeNotch
//
//  Main notch view that handles open/close states, hover detection,
//  and displays the notch UI with smooth animations.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: NotchViewModel
    @ObservedObject var nudgeManager = NudgeManager.shared
    @ObservedObject var settings = SettingsManager.shared

    @State private var isHovering: Bool = false
    @State private var hoverTask: Task<Void, Never>?

    private let spring = Animation.spring(.bouncy(duration: 0.4))

    // MARK: - Closed State Sizing

    /// Width of each side item (icon / timer) — kept equal for symmetry
    private let closedSideItemWidth: CGFloat = 44

    /// Width of the center black region (matches physical notch minus curve inset)
    private var closedCenterWidth: CGFloat {
        vm.closedNotchSize.width - cornerRadiusInsets.closed.top
    }

    /// Total frame width for the closed state (content + horizontal padding)
    private var closedContentWidth: CGFloat {
        2 * closedSideItemWidth + closedCenterWidth + 2 * cornerRadiusInsets.closed.bottom
    }

    // MARK: - Shape

    private var notchShape: NotchShape {
        NotchShape(
            topCornerRadius: vm.notchState == .open
                ? cornerRadiusInsets.opened.top
                : cornerRadiusInsets.closed.top,
            bottomCornerRadius: vm.notchState == .open
                ? cornerRadiusInsets.opened.bottom
                : cornerRadiusInsets.closed.bottom
        )
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // The notch container
                VStack(alignment: .leading, spacing: 0) {
                    // Header (always visible — serves as the closed notch bar)
                    headerContent

                    // Expanded content (only when open)
                    if vm.notchState == .open {
                        NudgeHomeView()
                            .transition(
                                .scale(scale: 0.85, anchor: .top)
                                .combined(with: .opacity)
                            )
                            .allowsHitTesting(vm.notchState == .open)
                    }
                }
                .padding(
                    .horizontal,
                    vm.notchState == .open
                        ? cornerRadiusInsets.opened.top
                        : cornerRadiusInsets.closed.bottom
                )
                .padding(
                    [.horizontal, .bottom],
                    vm.notchState == .open ? 12 : 0
                )
                .frame(
                    width: vm.notchState == .open
                        ? openNotchSize.width
                        : closedContentWidth,
                    alignment: .top
                )
                .background(.black)
                .clipShape(notchShape)
                .overlay(alignment: .top) {
                    // Top edge overlay for seamless blending with the real notch
                    Rectangle()
                        .fill(.black)
                        .frame(height: 1)
                        .padding(
                            .horizontal,
                            vm.notchState == .open
                                ? cornerRadiusInsets.opened.top
                                : cornerRadiusInsets.closed.top
                        )
                }
                .shadow(
                    color: (vm.notchState == .open || isHovering)
                        ? .black.opacity(0.6) : .clear,
                    radius: 6
                )
            }
            .animation(spring, value: vm.notchState)
            .contentShape(Rectangle())
            .onHover { handleHover($0) }
            .onTapGesture { tapToOpen() }
            .contextMenu {
                Button("Settings") {
                    SettingsWindowController.shared.showWindow()
                }
                Divider()
                Button("Quit NudgeNotch") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding(.bottom, 8)
        .frame(
            maxWidth: nudgeNotchWindowSize.width,
            maxHeight: nudgeNotchWindowSize.height,
            alignment: .top
        )
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    @ViewBuilder
    private var headerContent: some View {
        if vm.notchState == .open {
            openHeader
        } else {
            closedNotchContent
        }
    }

    /// Header when the notch is expanded
    private var openHeader: some View {
        HStack(spacing: 0) {
            // Left: App title
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.green)

                Text("NudgeNotch")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Center: Physical notch mask
            Rectangle()
                .fill(.black)
                .frame(width: vm.closedNotchSize.width)
                .mask { NotchShape() }

            // Right: Settings
            HStack(spacing: 8) {
                Button {
                    SettingsWindowController.shared.showWindow()
                } label: {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 28, height: 28)
                        .overlay {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(height: max(24, vm.effectiveClosedNotchHeight))
        .opacity(vm.notchState == .open ? 1 : 0)
        .blur(radius: vm.notchState == .closed ? 20 : 0)
    }

    /// Content shown when the notch is closed — live activity style
    private var closedNotchContent: some View {
        HStack(spacing: 0) {
            // Left: Icon for next upcoming nudge
            Group {
                if let nextType = nudgeManager.nextUpcomingNudgeType {
                    Image(systemName: nextType.icon)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(nextType.color.opacity(0.9))
                }
            }
            .frame(width: closedSideItemWidth, height: vm.effectiveClosedNotchHeight, alignment: .center)

            // Center: Black region matching the physical notch
            Rectangle()
                .fill(.black)
                .frame(width: closedCenterWidth)

            // Right: Countdown
            Group {
                if nudgeManager.nextUpcomingNudgeType != nil {
                    Text(nudgeManager.nextUpcomingCountdown)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.gray.opacity(0.9))
                }
            }
            .frame(width: closedSideItemWidth, height: vm.effectiveClosedNotchHeight, alignment: .center)
        }
        .frame(height: vm.effectiveClosedNotchHeight, alignment: .center)
    }

    // MARK: - Hover Handling

    private func handleHover(_ hovering: Bool) {
        hoverTask?.cancel()

        if hovering {
            withAnimation(spring) { isHovering = true }
            vm.cancelAutoClose()

            guard vm.notchState == .closed, settings.openOnHover else { return }

            hoverTask = Task {
                try? await Task.sleep(for: .milliseconds(200))
                guard !Task.isCancelled else { return }
                withAnimation(spring) { vm.open() }
            }
        } else {
            hoverTask = Task {
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else { return }

                withAnimation(spring) { isHovering = false }

                if vm.notchState == .open {
                    try? await Task.sleep(for: .milliseconds(800))
                    guard !Task.isCancelled else { return }
                    withAnimation(spring) { vm.close() }
                }
            }
        }
    }

    private func tapToOpen() {
        guard vm.notchState == .closed else { return }
        vm.cancelAutoClose()
        withAnimation(spring) { vm.open() }
    }
}

// MARK: - Preview

#Preview {
    let vm = NotchViewModel()
    vm.open()
    return ContentView()
        .environmentObject(vm)
        .frame(width: nudgeNotchWindowSize.width, height: nudgeNotchWindowSize.height)
}
