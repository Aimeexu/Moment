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
        Emotion(name: emotionName, emoji: emotionEmoji)
    }
    
    var voiceURL: URL? {
        guard let urlString = voiceURLString else { return nil }
        return URL(string: urlString)
    }
    
    var imageURLs: [URL] {
        imageURLStrings.compactMap { URL(string: $0) }
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