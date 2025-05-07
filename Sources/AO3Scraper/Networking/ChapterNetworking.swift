//
//  ChapterNetworking.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 3/1/25.
//

public class ChapterNetworking {
    /// Keeps track of the works loaded into memory
    public var worksCache: [String: Work] = [:]
    
    public init() { }
    
    /// Fetches the work at a given chapter
    /// - Parameters:
    ///   - workID: the unique identifier for the work
    ///   - chapterIndex: chapter index; defaults to 1; starts counting at 1
    /// - Returns: the work
    public func fetch(work workID: String, at chapterIndex: Int = 1) async -> Work? {
        // Return cached work if chapter is already loaded
        let work: Work
        if let worksCached = worksCache[workID] {
            work = worksCached
            
            // Chapter is already loaded
            if work.chapters[chapterIndex - 1] != nil {
                return work
            }
        } else {
            // Work hasn't been fetched
            work = Work(id: workID)
        }
        
        // Get chapterID from chapter index (only needed for chapters 2 and up)
        var chapterID = work.chapterID(for: chapterIndex)
        if chapterIndex > 1 && chapterID == nil {
            // ChapterList needs fetching
            let chapterListResult: Result<ChapterList?, Error> = await Networking.fetch(.workChapters(workID: workID))
            switch chapterListResult {
                case .success(let chapterList):
                    work.chapterList = chapterList
                    chapterID = work.chapterID(for: chapterIndex)
                    
                    if chapterID == nil {
                        Logging.log("Couldn't find chapterID for chapter \(chapterIndex) of work \(workID)")
                        return nil
                    }
                case .failure(let error):
                    Logging.log(error)
                    break
            }
        }
        
        // Fetch chapter
        let workResult: Result<Work?, Error> = await Networking.fetch(.work(work: work, chapterID: chapterID))
        switch workResult {
            case .success(let work):
                worksCache[workID] = work
            case .failure(let error):
                Logging.log(error)
                break
        }
        
        return worksCache[workID]
    }
}
