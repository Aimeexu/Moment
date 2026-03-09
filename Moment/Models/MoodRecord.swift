//
//  MoodRecord.swift
//  Moment
//
//  情绪记录模型
//

import Foundation
import SwiftData

@Model
final class MoodRecord {
    var id: UUID
    var emotionName: String
    var emotionEmoji: String
    var date: Date
    var textContent: String?
    var voiceURLString: String?
    var voiceDuration: TimeInterval?
    var imageURLStrings: [String]
    var bookmarkURLString: String?
    var bookmarkTitle: String?
    var tagNames: [String]
    var tagIcons: [String]
    
    init(
        id: UUID = UUID(),
        emotionName: String,
        emotionEmoji: String,
        date: Date = Date(),
        textContent: String? = nil,
        voiceURLString: String? = nil,
        voiceDuration: TimeInterval? = nil,
        imageURLStrings: [String] = [],
        bookmarkURLString: String? = nil,
        bookmarkTitle: String? = nil,
        tagNames: [String] = [],
        tagIcons: [String] = []
    ) {
        self.id = id
        self.emotionName = emotionName
        self.emotionEmoji = emotionEmoji
        self.date = date
        self.textContent = textContent
        self.voiceURLString = voiceURLString
        self.voiceDuration = voiceDuration
        self.imageURLStrings = imageURLStrings
        self.bookmarkURLString = bookmarkURLString
        self.bookmarkTitle = bookmarkTitle
        self.tagNames = tagNames
        self.tagIcons = tagIcons
    }
    
    // MARK: - Computed Properties
    
    var emotion: Emotion {
        // Try to find the emotion in the predefined list first
        if let foundEmotion = Emotion.allEmotions.first(where: { $0.name == emotionName && $0.emoji == emotionEmoji }) {
            return foundEmotion
        }
        
        // Fallback: create a basic emotion with default values
        return Emotion(
            name: emotionName,
            emoji: emotionEmoji,
            imageName: "Happy", // Default image
            backgroundColor: "E0E0E0" // Default gray color
        )
    }
    
    var voiceURL: URL? {
        guard let urlString = voiceURLString else { return nil }
        return URL(string: urlString)
    }
    
    var imageURLs: [URL] {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        return imageURLStrings.compactMap { urlString in
            // Handle different URL string formats
            let filename: String
            
            if let url = URL(string: urlString), url.scheme != nil {
                // It's a full URL, extract filename
                filename = url.lastPathComponent
            } else if urlString.hasPrefix("Documents/") {
                // It's a relative path starting with Documents/
                filename = String(urlString.dropFirst("Documents/".count))
            } else if urlString.contains("/") {
                // It's some other path, extract filename
                filename = (urlString as NSString).lastPathComponent
            } else {
                // It's already just a filename
                filename = urlString
            }
            
            let fullURL = documentsPath.appendingPathComponent(filename)
            
            // Verify file exists before returning URL
            if FileManager.default.fileExists(atPath: fullURL.path) {
                return fullURL
            } else {
                print("⚠️ Image file not found: \(filename)")
                return nil
            }
        }
    }
    
    var bookmarkURL: URL? {
        guard let urlString = bookmarkURLString else { return nil }
        return URL(string: urlString)
    }
    
    var tags: [Tag] {
        zip(tagNames, tagIcons).map { Tag(name: $0, icon: $1) }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    var formattedVoiceDuration: String? {
        guard let duration = voiceDuration else { return nil }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}