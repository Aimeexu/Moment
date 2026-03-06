//
//  RecordItemView.swift
//  Moment
//
//  记录列表项组件
//

import SwiftUI
import AVFoundation
import Combine

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying: Bool = false
    private var audioPlayer: AVAudioPlayer?
    
    func togglePlayback(for record: MoodRecord) {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback(for: record)
        }
    }
    
    private func startPlayback(for record: MoodRecord) {
        guard let voiceURL = record.voiceURL else { return }
        
        do {
            // 设置音频会话
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // 创建音频播放器
            audioPlayer = try AVAudioPlayer(contentsOf: voiceURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            isPlaying = true
        } catch {
            print("播放失败: \(error)")
            // 如果播放失败，回退到模拟播放
            simulatePlayback(for: record)
        }
    }
    
    private func simulatePlayback(for record: MoodRecord) {
        isPlaying = true
        
        // 模拟播放完成后自动停止
        if let duration = record.voiceDuration {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.stopPlayback()
            }
        } else {
            // 默认3秒后停止
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.stopPlayback()
            }
        }
    }
    
    private func stopPlayback() {
        isPlaying = false
        audioPlayer?.stop()
        audioPlayer = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.stopPlayback()
        }
    }
}

struct RecordItemView: View {
    let record: MoodRecord
    let onMoreTapped: () -> Void
    
    @StateObject private var audioManager = AudioPlayerManager()

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
                        Button(action: { audioManager.togglePlayback(for: record) }) {
                            HStack(spacing: 6) {
                                Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
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
                                            colors: audioManager.isPlaying ? 
                                                [Color(hex: "f5a5d1"), Color(hex: "a78bfa")] :
                                                [Color(hex: "a7e4d0"), Color(hex: "a7e4d0").opacity(0.6)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
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

