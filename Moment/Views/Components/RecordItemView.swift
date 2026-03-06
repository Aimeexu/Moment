//
//  RecordItemView.swift
//  Moment
//
//  记录列表项组件
//

import SwiftUI

struct RecordItemView: View {
    let record: MoodRecord
    let onMoreTapped: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Emoji
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "a78bfa").opacity(0.15),
                            Color(hex: "f5a5d1").opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text(record.emotion.emoji)
                        .font(.system(size: 24))
                )

            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Time
                Text(record.formattedDate)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "b8b8b8"))

                // Text
                if let text = record.textContent {
                    Text(text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "5a5a5a"))
                        .lineLimit(2)
                        .lineSpacing(4)
                }

                // Media
                HStack(spacing: 8) {
                    // Voice
                    if record.voiceURL != nil {
                        HStack(spacing: 6) {
                            Image(systemName: "waveform")
                                .font(.system(size: 12))
                            Text(record.formattedVoiceDuration ?? "")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "a7e4d0"), Color(hex: "a7e4d0").opacity(0.6)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }

                    // Images placeholder
                    ForEach(0..<min(record.imageURLs.count, 3), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "c8f7e4").opacity(0.5))
                            .frame(width: 50, height: 50)
                    }
                }

                // Tags
                if !record.tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(record.tags) { tag in
                            Text("\(tag.icon) \(tag.name)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(hex: "8b8b8b"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "a78bfa").opacity(0.1))
                                )
                        }
                    }
                }
            }
            
            Spacer()

            // More button
            Button(action: onMoreTapped) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "b8b8b8"))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
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

