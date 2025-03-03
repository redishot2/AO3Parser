//
//  UserInfo.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation

public struct UserInfo {
    
    public struct Counts {
        public let works: Int
        public let series: Int
        public let bookmarks: Int
        public let collections: Int
    }
    
    public struct ProfileInfo {
        public let username: String
        public let profilePicture: URL?
        public let joinDate: String?
        public let bio: AttributedString?
    }
    
    public let profileInfo: ProfileInfo
    public let counts: Counts
    
    public let fandoms: [Link]
    public let recentWorks: [FeedCardInfo]
    public let recentSeries: [FeedCardInfo]
    public let recentBookmarks: [FeedCardInfo]
}
