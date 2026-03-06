//
//  Tag.swift
//  Moment
//
//  标签模型
//

import Foundation

struct Tag: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    var isSelected: Bool = false

    static let defaultTags: [Tag] = [
        Tag(name: "工作", icon: "🏢"),
        Tag(name: "生活", icon: "🏠"),
        Tag(name: "学习", icon: "📚"),
        Tag(name: "社交", icon: "👥"),
        Tag(name: "健康", icon: "💪")
    ]
}