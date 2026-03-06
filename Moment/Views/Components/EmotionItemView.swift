//
//  EmotionItemView.swift
//  Moment
//
//  情绪选择项组件
//

import SwiftUI

struct EmotionItemView: View {
    let emotion: Emotion
    let action: () -> Void

    @State private var isHovered: Bool = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(emotion.emoji)
                    .font(.system(size: 40))
                    .scaleEffect(isHovered ? 1.15 : 1.0)
                    .rotationEffect(.degrees(isHovered ? -5 : 0))

                Text(emotion.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isHovered ? Color(hex: "a78bfa") : Color(hex: "8b8b8b"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "a78bfa").opacity(isHovered ? 0.1 : 0),
                                Color(hex: "f5a5d1").opacity(isHovered ? 0.1 : 0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.3)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    HStack {
        EmotionItemView(emotion: Emotion(name: "开心", emoji: "😊")) {}
        EmotionItemView(emotion: Emotion(name: "难过", emoji: "😢")) {}
    }
    .padding()
    .background(Color(hex: "faf8f6"))
}