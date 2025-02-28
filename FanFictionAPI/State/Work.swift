//
//  Work.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 2/28/25.
//

class Work {
    var storyInfo: StoryInfo?
    var aboutInfo: AboutInfo?
    var chapterList: ChapterList?
    
    var chapters: [Int: Chapter] = [:]
}
