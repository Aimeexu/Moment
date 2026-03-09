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
            HStack(spacing: 6) {
                Text(tag.icon)
                    .font(.system(size: 14))
                Text(tag.name)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : Color(hex: "6b7280"))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(backgroundView)
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "f472b6"), Color(hex: "ec4899")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(
                    color: Color(hex: "f472b6").opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        } else {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "e5e7eb"), lineWidth: 1)
                )
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 4,
                    x: 0,
                    y: 2
                )
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