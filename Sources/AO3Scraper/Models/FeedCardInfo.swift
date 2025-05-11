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
        public let fandoms: [String]
        public let relationships: [String]
        public let characters: [String]
        public let tags: [String]
        public let collections: [String]
    }
    
    public struct Stats: Codable {
        public let lastUpdated: String?
        public let words: String?
        public let chapters: String?
        public let comments: String?
        public let kudos: String?
        public let bookmarks: String?
        public let hits: String?
        public let language: String?
        
        public var completed: Bool {
            let chapterCount = getChapterCount()
            guard
                let written = Int(chapterCount.0),
                let expected = Int(chapterCount.1)
            else {
                return false
            }
            
            return written >= expected
        }
        
        /// Number of chapter in work. Nil means author has not specified
        public var totalChapters: Int? {
            return Int(getChapterCount().1)
        }
        
        private func getChapterCount() -> (String, String) {
            guard
                let chapterCountRaw = chapters?.split(separator: "/"),
                let written = chapterCountRaw.first,
                let expected = chapterCountRaw.last
            else {
                return ("0", "0")
            }
            
            return (String(written), String(expected))
        }
    }
    
    public let title: String?
    public let workID: String
    public let authors: [String]
    public let summary: AttributedString?
    public let rating: StoryInfo.Rating?
    public let tags: Tags
    public let stats: Stats
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(workID)
        hasher.combine(authors)
    }
    
    public static func == (lhs: FeedCardInfo, rhs: FeedCardInfo) -> Bool {
        lhs.workID == rhs.workID
    }
}
