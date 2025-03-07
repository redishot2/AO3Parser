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
        public let fandoms: [LinkInfo]
        public let relationships: [LinkInfo]
        public let characters: [LinkInfo]
        public let tags: [LinkInfo]
        public let collections: [LinkInfo]
    }
    
    public struct Stats: Codable {
        public let lastUpdated: String?
        public let words: String?
        public let chapters: LinkInfo?
        public let comments: LinkInfo?
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
                let chapterCountRaw = chapters?.name.split(separator: "/"),
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
