//
//  SettingsView.swift
//  Moment
//
//  设置页面
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel

    @State private var showToast: Bool = false

    var body: some View {
        ZStack {
            // Background
            BackgroundDecorations()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("设置")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "a78bfa"), Color(hex: "f5a5d1")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Spacer()
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)

                    // Privacy Section
                    SettingsSectionView(title: "隐私保护") {
                        SettingsItemView(
                            icon: "lock.fill",
                            title: "应用锁",
                            showToggle: true,
                            isToggleOn: viewModel.isAppLockEnabled,
                            toggleAction: { viewModel.isAppLockEnabled.toggle() }
                        )
                    }
                    .padding(.horizontal, 20)

                    // Data Management Section
                    SettingsSectionView(title: "数据管理") {
                        SettingsItemView(
                            icon: "tag.fill",
                            title: "标签管理",
                            subtitle: "\(viewModel.availableTags.count)个标签"
                        ) {
                            showToast = true
                        }

                        Divider()
                            .padding(.leading, 52)
                            .background(Color(hex: "a78bfa").opacity(0.05))

                        SettingsItemView(
                            icon: "square.and.arrow.up",
                            title: "导出数据"
                        ) {
                            showToast = true
                        }

                        Divider()
                            .padding(.leading, 52)
                            .background(Color(hex: "a78bfa").opacity(0.05))

                        SettingsItemView(
                            icon: "trash.fill",
                            title: "清除数据",
                            isDanger: true
                        ) {
                            showToast = true
                        }
                    }
                    .padding(.horizontal, 20)

                    // Appearance Section
                    SettingsSectionView(title: "外观") {
                        SettingsItemView(
                            icon: "moon.fill",
                            title: "深色模式",
                            showToggle: true,
                            isToggleOn: viewModel.isDarkModeEnabled,
                            toggleAction: { viewModel.isDarkModeEnabled.toggle() }
                        )
                    }
                    .padding(.horizontal, 20)

                    // About Section
                    SettingsSectionView(title: "关于") {
                        SettingsItemView(
                            icon: "info.circle.fill",
                            title: "版本信息",
                            subtitle: "v1.0.0"
                        ) {
                            showToast = true
                        }

                        Divider()
                            .padding(.leading, 52)
                            .background(Color(hex: "a78bfa").opacity(0.05))

                        SettingsItemView(
                            icon: "envelope.fill",
                            title: "反馈与建议"
                        ) {
                            showToast = true
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 100)
                }
            }
        }
        .toast(isShowing: $showToast, message: "提示")
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
    }
}

#Preview {
    SettingsView(viewModel: AppViewModel())
}