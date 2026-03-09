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
                .frame(width: 100, height: 100)
                .overlay(
                    Text(record.emotion.emoji)
                        .font(.system(size: 48))
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

                    // Images
                    if !record.imageURLs.isEmpty {
                        RecordImagesGrid(imageURLs: record.imageURLs)
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


// 记录图片缩略图组件
struct RecordImageThumbnail: View {
    let imageURL: URL
    @State private var image: UIImage?
    @State private var isLoading: Bool = true
    @State private var loadFailed: Bool = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: "f5f5f5"))
            .overlay(
                Group {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    } else if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(Color(hex: "a78bfa"))
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: loadFailed ? "exclamationmark.triangle" : "photo")
                                .font(.system(size: 24))
                                .foregroundColor(loadFailed ? Color(hex: "f5a5d1") : Color(hex: "b8b8b8"))
                            
                            if loadFailed {
                                Text("加载失败")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "b8b8b8"))
                            }
                        }
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 4,
                x: 0,
                y: 2
            )
            .onAppear {
                loadImage()
            }
    }
    
    private func loadImage() {
        print("🖼️ Loading image from: \(imageURL.absoluteString)")
        print("🖼️ File path: \(imageURL.path)")
        print("🖼️ URL scheme: \(imageURL.scheme ?? "no scheme")")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Check if file exists
                let fileExists = FileManager.default.fileExists(atPath: imageURL.path)
                print("🖼️ File exists: \(fileExists)")
                
                guard fileExists else {
                    print("❌ Image file not found at path: \(imageURL.path)")
                    // List directory contents for debugging
                    let parentDir = imageURL.deletingLastPathComponent()
                    if let contents = try? FileManager.default.contentsOfDirectory(atPath: parentDir.path) {
                        print("📁 Directory contents: \(contents)")
                    }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.loadFailed = true
                    }
                    return
                }
                
                print("✅ Image file exists, loading data...")
                let imageData = try Data(contentsOf: imageURL)
                print("✅ Image data loaded, size: \(imageData.count) bytes")
                
                if let uiImage = UIImage(data: imageData) {
                    print("✅ UIImage created successfully, size: \(uiImage.size)")
                    DispatchQueue.main.async {
                        self.image = uiImage
                        self.isLoading = false
                    }
                } else {
                    print("❌ Failed to create UIImage from data")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.loadFailed = true
                    }
                }
            } catch {
                print("❌ Failed to load image from \(imageURL): \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.loadFailed = true
                }
            }
        }
    }
}

// 记录图片网格布局组件
struct RecordImagesGrid: View {
    let imageURLs: [URL]
    
    var body: some View {
        VStack(spacing: 8) {
            if imageURLs.count == 1 {
                // 单张图片：占屏幕宽度的2/3
                RecordImageThumbnail(imageURL: imageURLs[0])
                    .aspectRatio(4/3, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(maxWidth: 250) // 限制最大宽度
            } else if imageURLs.count > 1 {
                // 多张图片：一行两张
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ], spacing: 8) {
                    ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, imageURL in
                        RecordImageThumbnail(imageURL: imageURL)
                            .aspectRatio(4/3, contentMode: .fit)
                    }
                }
            }
        }
        .onAppear {
            print("🎯 RecordImagesGrid appeared with \(imageURLs.count) images")
            for (index, url) in imageURLs.enumerated() {
                print("🎯 Image \(index): \(url.absoluteString)")
                print("🎯 Image \(index) path: \(url.path)")
                print("🎯 Image \(index) file exists: \(FileManager.default.fileExists(atPath: url.path))")
            }
        }
    }
}