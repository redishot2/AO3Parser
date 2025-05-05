//
//  FeedInfo.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
import SwiftUI

public class FeedInfo {
    @Published public private(set) var feedInfo: [FeedCardInfo]
    public let pagesCount: Int
    public let filter: FeedFilterInfo
    
    public init(feedInfo: [FeedCardInfo], pagesCount: Int, filter: FeedFilterInfo) {
        self.feedInfo = feedInfo
        self.pagesCount = pagesCount
        self.filter = filter
    }
    
    public func addFeedInfo(from newFeedInfo: FeedInfo) {
        feedInfo.append(contentsOf: newFeedInfo.feedInfo)
    }
}

public struct FeedFilterInfo {
    public struct FilterInfo: Hashable {
        public let name: String
        public let id: String
    }
    
    public var fandomName: String
    
    public var ratings:        [FilterInfo]
    public var warnings:       [FilterInfo]
    public var categories:     [FilterInfo]
    public var fandoms:        [FilterInfo]
    public var characters:     [FilterInfo]
    public var relationships:  [FilterInfo]
    public var additionalTags: [FilterInfo]
    public var languages:      [FilterInfo]
    
    public static func empty(fandom: String) -> FeedFilterInfo {
        return FeedFilterInfo(fandomName: "", ratings: [], warnings: [], categories: [], fandoms: [], characters: [], relationships: [], additionalTags: [], languages: [])
    }
}
