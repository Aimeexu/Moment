//
//  Emotion.swift
//  Moment
//
//  情绪模型
//

import Foundation

struct Emotion: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let emoji: String
    let imageName: String
    let backgroundColor: String
    
    init(name: String, emoji: String, imageName: String, backgroundColor: String) {
        self.name = name
        self.emoji = emoji
        self.imageName = imageName
        self.backgroundColor = "#00000000"
    }

    static let allEmotions: [Emotion] = [
        Emotion(name: "Happy", emoji: "😊", imageName: "Happy", backgroundColor: "FBF8F0"),
        Emotion(name: "Loved", emoji: "🥰", imageName: "Loved", backgroundColor: "FBF8F0"),
        Emotion(name: "Proud", emoji: "😎", imageName: "Proud", backgroundColor: "FBF8F0"),
        Emotion(name: "Tired", emoji: "😩", imageName: "Tired", backgroundColor: "FBF8F0"),
        Emotion(name: "Sad", emoji: "😢", imageName: "Sad", backgroundColor: "FBF8F0"),
        Emotion(name: "Angry", emoji: "😠", imageName: "Angry", backgroundColor: "FBF8F0"),
        Emotion(name: "Anxious", emoji: "😰", imageName: "Anxious", backgroundColor: "FBF8F0"),
        Emotion(name: "Down", emoji: "😔", imageName: "Down", backgroundColor: "FBF8F0"),
        Emotion(name: "Calm", emoji: "😌", imageName: "Calm", backgroundColor: "FBF8F0")
    ]
}
