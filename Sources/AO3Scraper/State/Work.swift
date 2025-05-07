//
//  Work.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 2/28/25.
//

public class Work {
    /// The identifying number for this work
    public let id: String
    
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
    
    public init(id: String) {
        self.id = id
    }
    
    /// Converts chapter index to chapterID used in url creation
    /// - Parameter index: chapter index; starts counting at 1
    /// - Returns: chapterID
    internal func chapterID(for index: Int) -> String? {
        guard let chapterList = chapterList else { return nil }
        guard index >= 1 && index <= chapterList.chapterIDs.count else { return nil }
        
        return chapterList.chapterIDs[index - 1]
    }
    
    internal func chapterIndex(for chapterID: String?) -> Int? {
        guard let chapterID = chapterID else { return nil }
        
        return chapterList?.chapterIDs.firstIndex(of: chapterID)
    }
}
