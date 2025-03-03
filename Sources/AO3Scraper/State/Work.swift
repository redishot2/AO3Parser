//
//  Work.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 2/28/25.
//

public class Work {
    /// The identifying number for this work
    public let id: String
    
    /// The current chapter index for use in chapterList
    internal var currentChapterIndex: Int
    
    /// Returns the current chapter the user is on
    public var currentChapter: Chapter? {
        guard currentChapterIndex < chapters.count else { return nil }
        return chapters[currentChapterIndex]
    }
    
    /// A list of chapter names and IDs for the given work
    public var chapterList: ChapterList?
    
    /// A dict of chapters that have been loaded
    public var chapters: [Int: Chapter] = [:]
    
    /// Information about the fandom, relationships, etc
    public var storyInfo: StoryInfo?
    
    /// Information about the work's title, author, etc
    public var aboutInfo: AboutInfo?
    
    /// If vital information is missing
    public var shouldParseAdditionalInfo: Bool {
        storyInfo == nil || aboutInfo == nil
    }
    
    public init(id: String, currentChapterIndex: Int = 0) {
        self.id = id
        self.currentChapterIndex = currentChapterIndex
    }
    
    /// Saves a chapter at the current chapter index
    internal func saveAsCurrentChapter(_ chapter: Chapter) {
        chapters[currentChapterIndex] = chapter
    }
}
