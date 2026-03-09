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
        HStack(alignment: .top, spacing: 16) {
            // Emotion Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: record.emotion.backgroundColor))
                    .frame(width: 64, height: 64)
                    .shadow(
                        color: Color(hex: "a78bfa").opacity(0.15),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(record.emotion.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
            }

            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Time
                Text(record.formattedDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "999999"))

                // Content Card
                VStack(alignment: .leading, spacing: 12) {
                    // Text Content
                    if let text = record.textContent {
                        Text(text)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "333333"))
                            .lineLimit(3)
                            .lineSpacing(2)
                    }

                    // Media Content
                    VStack(alignment: .leading, spacing: 8) {
                        // Voice
                        if record.voiceURL != nil {
                            Button(action: { audioManager.togglePlayback(for: record) }) {
                                HStack(spacing: 8) {
                                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 12, weight: .medium))
                                    Text(record.formattedVoiceDuration ?? "00:00")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: audioManager.isPlaying ? 
                                                    [Color(hex: "f5a5d1"), Color(hex: "a78bfa")] :
                                                    [Color(hex: "a7e4d0"), Color(hex: "7dd3fc")],
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
                            ForEach(record.tags.prefix(3)) { tag in
                                Text("\(tag.icon) \(tag.name)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Color(hex: "666666"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color(hex: "f5f5f5"))
                                    )
                            }
                            
                            if record.tags.count > 3 {
                                Text("+\(record.tags.count - 3)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Color(hex: "999999"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color(hex: "f0f0f0"))
                                    )
                            }
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "e8f4f8"))
                )
            }
            
            Spacer()

            // More button
            Button(action: onMoreTapped) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "cccccc"))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
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
}


// 记录图片缩略图组件
struct RecordImageThumbnail: View {
    let imageURL: URL
    @State private var image: UIImage?
    @State private var isLoading: Bool = true
    @State private var loadFailed: Bool = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: "f8f9fa"))
            .overlay(
                Group {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    } else if isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                            .tint(Color(hex: "a78bfa"))
                    } else {
                        VStack(spacing: 2) {
                            Image(systemName: loadFailed ? "exclamationmark.triangle.fill" : "photo")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(loadFailed ? Color(hex: "ff6b6b") : Color(hex: "cccccc"))
                            
                            if loadFailed {
                                Text("加载失败")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(Color(hex: "999999"))
                            }
                        }
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(
                color: Color.black.opacity(0.06),
                radius: 3,
                x: 0,
                y: 1
            )
            .onAppear {
                loadImage()
            }
    }
    
    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Check if file exists
                guard FileManager.default.fileExists(atPath: self.imageURL.path) else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.loadFailed = true
                    }
                    return
                }
                
                // Load image data
                let imageData = try Data(contentsOf: self.imageURL)
                
                guard let uiImage = UIImage(data: imageData) else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.loadFailed = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.image = uiImage
                    self.isLoading = false
                }
            } catch {
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
        VStack(spacing: 6) {
            if imageURLs.count == 1 {
                // 单张图片：较小尺寸
                RecordImageThumbnail(imageURL: imageURLs[0])
                    .aspectRatio(4/3, contentMode: .fit)
                    .frame(maxWidth: 120, maxHeight: 90)
            } else if imageURLs.count > 1 {
                // 多张图片：网格布局
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 6),
                    GridItem(.flexible(), spacing: 6)
                ], spacing: 6) {
                    ForEach(Array(imageURLs.prefix(4).enumerated()), id: \.offset) { index, imageURL in
                        RecordImageThumbnail(imageURL: imageURL)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxWidth: 60, maxHeight: 60)
                            .overlay(
                                // Show count overlay for 4th image if there are more
                                Group {
                                    if index == 3 && imageURLs.count > 4 {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.black.opacity(0.6))
                                            .overlay(
                                                Text("+\(imageURLs.count - 3)")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }
                            )
                    }
                }
                .frame(maxWidth: 132) // 60*2 + 6*2
            }
        }
        .onAppear {
            // Only log if there are issues with image loading
            if imageURLs.isEmpty {
                print("⚠️ RecordImagesGrid: No images to display")
            }
        }
    }
}