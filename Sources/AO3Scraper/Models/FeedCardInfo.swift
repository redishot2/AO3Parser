//
//  FeedCardInfo.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation

public struct FeedCardInfo: Hashable, Codable {
    
    public struct Tags: Codable {
        public let warnings: [StoryInfo.Warning]
        public let category: StoryInfo.Category?
        public let fandoms: [Link]
        public let relationships: [Link]
        public let characters: [Link]
        public let tags: [Link]
        public let collections: [Link]
    }
    
    public struct Stats: Codable {
        public let lastUpdated: String?
        public let words: String?
        public let chapters: Link?
        public let comments: Link?
        public let kudos: String?
        public let bookmarks: String?
        public let hits: String?
        public let language: String?
        
        public var completed: Bool? {
            return totalChapters != nil
        }
        
        /// Number of chapter in work. Nil means author has not specified
        public var totalChapters: Int? {
            guard
                let chapterCountRaw = chapters?.name.split(separator: "/").last,
                    chapterCountRaw != "?"
            else { return nil }
            guard
                let chapterCount = String(chapterCountRaw).toInt()
            else { return nil }
            
            return chapterCount
        }
    }
    
    public let title: String?
    public let workID: String
    public let author: String
    public let summary: AttributedString?
    public let rating: StoryInfo.Rating?
    public let tags: Tags
    public let stats: Stats
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(workID)
        hasher.combine(author)
    }
    
    public static func == (lhs: FeedCardInfo, rhs: FeedCardInfo) -> Bool {
        lhs.workID == rhs.workID
    }
}
