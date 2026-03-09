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
        .padding(.top, 16)
        .padding(.bottom, 34) // 保持底部安全区域padding
        .background(
            // 自定义形状，左右上角有圆弧
            TabBarShape()
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 12,
                    x: 0,
                    y: -4
                )
                .ignoresSafeArea(.container, edges: .bottom) // 忽略底部安全区域
        )
    }
}

// 自定义TabBar形状，左右上角有圆弧
struct TabBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerRadius: CGFloat = 60
        
        // 从左下角开始
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        
        // 左边线到左上角圆弧开始点
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // 左上角圆弧
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        // 顶边线到右上角圆弧开始点
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: 0))
        
        // 右上角圆弧
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // 右边线到右下角
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // 底边线回到起点
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        
        return path
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