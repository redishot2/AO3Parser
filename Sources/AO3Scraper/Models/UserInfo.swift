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
    
    struct ProfileInfo {
        let username: String
        let profilePicture: URL?
        let joinDate: String?
        let bio: AttributedString?
    }
    
    let profileInfo: ProfileInfo
    let counts: Counts
    
    let fandoms: [Link]
    let recentWorks: [FeedCardInfo]
    let recentSeries: [FeedCardInfo]
    let recentBookmarks: [FeedCardInfo]
}
