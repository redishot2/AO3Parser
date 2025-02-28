//
//  History.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation

struct History {
    
    static var shared = History()
    
    private enum Constants {
        static let progress = "progress"
    }
    
    private(set) var works: [SaveObject] {
        didSet {
            if let encoded = try? JSONEncoder().encode(works) {
                UserDefaults.standard.set(encoded, forKey: Constants.progress)
            }
        }
    }
    
    init() {
        if let data = UserDefaults.standard.object(forKey: Constants.progress) as? Data, let progress = try? JSONDecoder().decode([SaveObject].self, from: data) {
            self.works = progress
        } else {
            self.works = []
        }
    }
    
    mutating func updateProgress(on feedCardItem: FeedCardInfo, work: String, chapter: Int, totalChapters: Int) {
        // Check for existing save
        if let existingIndex = works.firstIndex(where: { $0.feedCardInfo.workID == feedCardItem.workID }) {
            var existingHistory = works[existingIndex]
            
            guard chapter > existingHistory.chapter else { return }
            
            existingHistory.updateDate = Date()
            existingHistory.chapter = chapter
            works[existingIndex] = existingHistory
        } else {
            works.append(SaveObject(chapter: chapter, updateDate: Date(), feedCardInfo: feedCardItem))
        }
    }
    
    public static func chapterIndex(for feedCardInfo: FeedCardInfo) -> Int {
        let work = History.shared.works.first(where: { $0.feedCardInfo.workID == feedCardInfo.workID })
        return work?.chapter ?? 0
    }
    
    public static func getUnfinishedWorks() -> [SaveObject] {
        History.shared.works
            .filter({ !$0.isComplete })
            .sorted(by: { $0.updateDate > $1.updateDate })
    }
    
    public static func getFinishedWorks() -> [SaveObject] {
        History.shared.works
            .filter({ $0.isComplete })
            .sorted(by: { $0.updateDate > $1.updateDate })
    }
    
    public static func lastUnfinished() -> SaveObject? {
        getUnfinishedWorks().first
    }
}

struct SaveObject: Codable, Identifiable, Hashable {
    var id = UUID()
    
    var chapter: Int
    var updateDate: Date
    
    let feedCardInfo: FeedCardInfo
    
    /// User has finished reading this work
    var isComplete: Bool {
        guard let chapterCount = feedCardInfo.stats.totalChapters else { return false }
        
        return chapter + 1 >= chapterCount
    }
    
    /// Human readable progress amount
    var progressText: String {
        if isComplete {
            return completedText
        } else {
            return unfinishedProgressText
        }
    }
    
    var progress: Double {
        guard let chapterCount = feedCardInfo.stats.totalChapters else {
            return 0.33
        }
        
        return Double(chapter + 1) / Double(chapterCount)
    }
    
    private var completedText: String {
        let humanDate = updateDate.formatted(date: .complete, time: .omitted)
        
        return "Last read on \(humanDate)"
    }
    
    private var unfinishedProgressText: String {
        let chapterName = "\(chapter + 1)"
        
        var totalChapterName = ""
        if let totalChapters = feedCardInfo.stats.totalChapters {
            totalChapterName = "\(totalChapters) chapter"
            if totalChapters > 1 {
                totalChapterName += "s"
            }
        } else {
            totalChapterName = "an unknown number of chapters"
        }
        
        return "Completed \(chapterName) of \(totalChapterName)"
    }
}
