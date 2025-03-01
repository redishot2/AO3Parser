//
//  Work.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 2/28/25.
//

public class Work {
    let id: String
    var currentChapter: Int = 0
    
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
}
