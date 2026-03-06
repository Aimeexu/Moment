//
//  TagItemView.swift
//  Moment
//
//  标签选择项组件
//

import SwiftUI

struct TagItemView: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(tag.icon)
                Text(tag.name)
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(isSelected ? .white : Color(hex: "8b8b8b"))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(backgroundView)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.clear : Color(hex: "a78bfa").opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "a78bfa"), Color(hex: "f5a5d1")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.6))
        }
    }
}

#Preview {
    HStack {
        TagItemView(
            tag: Tag(name: "工作", icon: "🏢"),
            isSelected: false
        ) {}
        TagItemView(
            tag: Tag(name: "生活", icon: "🏠"),
            isSelected: true
        ) {}
    }
    .padding()
    .background(Color(hex: "faf8f6"))
}