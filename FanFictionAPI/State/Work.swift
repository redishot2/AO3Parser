//
//  Work.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 2/28/25.
//

public class Work {
    let id: String
    private var currentChapterIndex: Int = 0
    var currentChapter: Chapter? {
        guard currentChapterIndex < chapters.count else { return nil }
        return chapters[currentChapterIndex]
    }
    
    var storyInfo: StoryInfo?
    var aboutInfo: AboutInfo?
    var shouldParseAdditionalInfo: Bool {
        storyInfo == nil || aboutInfo == nil
    }
    
    var chapterList: ChapterList?
    
    var chapters: [Int: Chapter] = [:]
    
    public init(id: String) {
        self.id = id
    }
    
    internal func saveAsCurrentChapter(_ chapter: Chapter) {
        chapters[currentChapterIndex] = chapter
    }
}
