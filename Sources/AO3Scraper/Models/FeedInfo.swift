//
//  FeedInfo.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation

public struct FeedInfo {
    let feedInfo: [FeedCardInfo]
    let pagesCount: Int
    let filter: FeedFilterInfo
}

public struct FeedFilterInfo {
    public struct FilterInfo: Hashable {
        let name: String
        let id: String
    }
    
    var fandomName: String
    
    var ratings:        [FilterInfo]
    var warnings:       [FilterInfo]
    var categories:     [FilterInfo]
    var fandoms:        [FilterInfo]
    var characters:     [FilterInfo]
    var relationships:  [FilterInfo]
    var additionalTags: [FilterInfo]
    var languages:      [FilterInfo]
    
    static func empty(fandom: String) -> FeedFilterInfo {
        return FeedFilterInfo(fandomName: "", ratings: [], warnings: [], categories: [], fandoms: [], characters: [], relationships: [], additionalTags: [], languages: [])
    }
}
