//
//  SettingsItemView.swift
//  Moment
//
//  设置列表项组件
//

import SwiftUI

struct SettingsItemView: View {
    let icon: String
    let title: String
    let subtitle: String?
    let isDanger: Bool
    let showToggle: Bool
    let isToggleOn: Bool
    let showArrow: Bool
    let action: (() -> Void)?
    let toggleAction: (() -> Void)?

    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        isDanger: Bool = false,
        showToggle: Bool = false,
        isToggleOn: Bool = false,
        showArrow: Bool = true,
        action: (() -> Void)? = nil,
        toggleAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isDanger = isDanger
        self.showToggle = showToggle
        self.isToggleOn = isToggleOn
        self.showArrow = showArrow
        self.action = action
        self.toggleAction = toggleAction
    }

    var body: some View {
        Button(action: {
            if showToggle {
                toggleAction?()
            } else {
                action?()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isDanger ? Color(hex: "ff6b6b") : Color(hex: "a78bfa"))
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isDanger ? Color(hex: "ff6b6b") : Color(hex: "5a5a5a"))

                Spacer()

                if showToggle {
                    Toggle("", isOn: Binding(
                        get: { isToggleOn },
                        set: { _ in toggleAction?() }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "a78bfa")))
                } else {
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "b8b8b8"))
                    }

                    if showArrow {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "b8b8b8"))
                    }
                }
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "b8b8b8"))
                .textCase(.uppercase)
                .tracking(0.8)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "a78bfa").opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        SettingsSectionView(title: "隐私保护") {
            SettingsItemView(
                icon: "lock.fill",
                title: "应用锁",
                showToggle: true,
                isToggleOn: false
            ) {}
        }

        SettingsSectionView(title: "数据管理") {
            SettingsItemView(
                icon: "tag.fill",
                title: "标签管理",
                subtitle: "5个标签"
            ) {}

            Divider()
                .padding(.leading, 52)
                .background(Color(hex: "a78bfa").opacity(0.05))

            SettingsItemView(
                icon: "square.and.arrow.up",
                title: "导出数据"
            ) {}

            Divider()
                .padding(.leading, 52)
                .background(Color(hex: "a78bfa").opacity(0.05))

            SettingsItemView(
                icon: "trash.fill",
                title: "清除数据",
                isDanger: true
            ) {}
        }
    }
    .padding()
    .background(Color(hex: "faf8f6"))
}