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

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Image container with background color
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: emotion.backgroundColor))
                    .frame(width: 80, height: 90)
                    .overlay(
                        Image(emotion.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                    )
                    .scaleEffect(isPressed ? 1.11 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)

                // Emotion name
                Text(emotion.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "333333"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "FBF8F0"))
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: 8,
                        x: 0,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    HStack {
        EmotionItemView(emotion: Emotion(name: "기쁨", emoji: "😊", imageName: "Happy", backgroundColor: "FFE066")) {}
        EmotionItemView(emotion: Emotion(name: "슬픔", emoji: "😢", imageName: "Sad", backgroundColor: "87CEEB")) {}
    }
    .padding()
    .background(Color(hex: "faf8f6"))
}
