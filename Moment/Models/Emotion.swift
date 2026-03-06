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

    static let allEmotions: [Emotion] = [
        Emotion(name: "开心", emoji: "😊"),
        Emotion(name: "幸福", emoji: "🥰"),
        Emotion(name: "自豪", emoji: "😎"),
        Emotion(name: "疲惫", emoji: "😩"),
        Emotion(name: "难过", emoji: "😢"),
        Emotion(name: "生气", emoji: "😠"),
        Emotion(name: "焦虑", emoji: "😰"),
        Emotion(name: "低落", emoji: "😔"),
        Emotion(name: "平静", emoji: "😌")
    ]
}