//
//  ToastView.swift
//  Moment
//
//  Toast提示组件
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.8))
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String

    func body(content: Content) -> some View {
        ZStack {
            content

            if isShowing {
                VStack {
                    Spacer()
                    ToastView(message: message)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.3), value: isShowing)
                }
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        modifier(ToastModifier(isShowing: isShowing, message: message))
    }
}

#Preview {
    VStack {
        ToastView(message: "记录已保存")
    }
}