//
//  Work.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 2/28/25.
//

public class Work {
    let id: String
    private var currentChapterIndex: Int
    
    var currentChapter: Chapter? {
        guard currentChapterIndex < chapters.count else { return nil }
        return chapters[currentChapterIndex]
    }
    
    var storyInfo: StoryInfo?
    var aboutInfo: AboutInfo?
    var chapterList: ChapterList?
    var shouldParseAdditionalInfo: Bool {
        storyInfo == nil || aboutInfo == nil
    }
    
    var chapters: [Int: Chapter] = [:]
    
    public init(id: String, currentChapterIndex: Int = 0) {
        self.id = id
        self.currentChapterIndex = currentChapterIndex
    }
    
    internal func saveAsCurrentChapter(_ chapter: Chapter) {
        chapters[currentChapterIndex] = chapter
    }
}
