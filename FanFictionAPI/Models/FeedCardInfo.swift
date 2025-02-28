//
//  FeedCardInfo.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation

public struct FeedCardInfo: Hashable, Codable {
    
    struct Tags: Codable {
        let warnings: [StoryInfo.Warning]
        let category: StoryInfo.Category?
        let fandoms: [Link]
        let relationships: [Link]
        let characters: [Link]
        let tags: [Link]
        let collections: [Link]
    }
    
    struct Stats: Codable {
        let lastUpdated: String?
        let words: String?
        let chapters: Link?
        let comments: Link?
        let kudos: String?
        let bookmarks: String?
        let hits: String?
        let language: String?
        
        var completed: Bool? {
            return totalChapters != nil
        }
        
        /// Number of chapter in work. Nil means author has not specified
        var totalChapters: Int? {
            guard
                let chapterCountRaw = chapters?.name.split(separator: "/").last,
                    chapterCountRaw != "?"
            else { return nil }
            guard
                let chapterCount = Int(chapterCountRaw)
            else { return nil }
            
            return chapterCount
        }
    }
    
    let title: String?
    let workID: String
    let author: String
    let summary: AttributedString?
    let rating: StoryInfo.Rating?
    let tags: Tags
    let stats: Stats
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(workID)
        hasher.combine(author)
    }
    
    public static func == (lhs: FeedCardInfo, rhs: FeedCardInfo) -> Bool {
        lhs.workID == rhs.workID
    }
}
