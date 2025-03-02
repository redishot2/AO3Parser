//
//  ChapterNetworking.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 3/1/25.
//

class ChapterNetworking {
    /// Keeps track of the works loaded into memory
    var worksCache: [String: Work] = [:]
    
    /// Fetches the work at a given chapter
    /// - Parameters:
    ///   - workID: the unique identifier for the work
    ///   - chapterIndex: chapter index; defaults to 0
    /// - Returns: the next chapter in the work
    public func fetch(work workID: String, at chapterIndex: Int = 0) async -> Chapter? {
        let work: Work
        if let worksCached = worksCache[workID] {
            work = worksCached
        } else {
            work = Work(id: workID, currentChapterIndex: chapterIndex)
        }
        
        var chapterID: String? = nil
        if chapterIndex > 0 {
            let chapterListResult: Result<ChapterList?, Error> = await Networking.fetch(.workChapters(workID: workID))
            switch chapterListResult {
                case .success(let chapterList):
                    work.chapterList = chapterList
                    if work.currentChapterIndex >= work.chapterList!.chapters.count {
                        chapterID = work.chapterList?.chapters[work.currentChapterIndex].url
                    }
                case .failure:
                    break
            }
        }
        
        let workResult: Result<Work?, Error> = await Networking.fetch(.work(work: work, chapterID: chapterID))
        switch workResult {
            case .success(let work):
                worksCache[workID] = work
            case .failure:
                break
        }
        
        return worksCache[workID]?.currentChapter
    }
    
    /// Fetches the next chapter in a given work. If work is not loaded yet, load first chapter
    ///   - workID:
    /// - Parameter workID: the unique identifier for the work
    /// - Returns: the next chapter in the work
    public func fetchNextChapter(for workID: String) async -> Chapter? {
        if let work = worksCache[workID] {
            return await fetch(work: workID, at: work.currentChapterIndex + 1)
        } else {
            return await fetch(work: workID)
        }
    }
}
