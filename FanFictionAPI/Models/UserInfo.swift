//
//  UserInfo.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation

public struct UserInfo {
    
    struct Counts {
        let works: Int
        let series: Int
        let bookmarks: Int
        let collections: Int
    }
    
    let username: String
    let profilePicture: URL?
    let joinDate: String?
    let bio: AttributedString?
    let counts: Counts
    
    let fandoms: [Link]
    let recentWorks: [FeedCardInfo]
    let recentSeries: [FeedCardInfo]
    let recentBookmarks: [FeedCardInfo]
    let gifts: [FeedCardInfo]
}
