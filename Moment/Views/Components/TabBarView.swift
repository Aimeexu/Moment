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
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.bottom, 34) // Safe area bottom padding
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 12,
                    x: 0,
                    y: -4
                )
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
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isActive ? Color(hex: "333333") : Color(hex: "999999"))

                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isActive ? Color(hex: "333333") : Color(hex: "999999"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .scaleEffect(isActive ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isActive)
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