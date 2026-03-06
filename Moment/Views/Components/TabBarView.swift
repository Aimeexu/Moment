//
//  TabBarView.swift
//  Moment
//
//  底部导航栏组件
//

import SwiftUI

struct TabBarView: View {
    @Binding var currentPage: AppPage

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(
                icon: "house.fill",
                label: "首页",
                isActive: currentPage == .home
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage = .home
                }
            }

            TabBarItem(
                icon: "list.bullet.clipboard.fill",
                label: "记录",
                isActive: currentPage == .list
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage = .list
                }
            }

            TabBarItem(
                icon: "gearshape.fill",
                label: "设置",
                isActive: currentPage == .settings
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage = .settings
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.bottom, 8)
        .background(
            Rectangle()
                .fill(Color.white.opacity(0.95))
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.05))
                .frame(height: 1),
            alignment: .top
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isActive ? Color(hex: "a78bfa") : Color(hex: "b8b8b8"))

                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isActive ? Color(hex: "a78bfa") : Color(hex: "b8b8b8"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        Spacer()
        TabBarView(currentPage: .constant(.home))
    }
    .background(Color(hex: "faf8f6"))
}