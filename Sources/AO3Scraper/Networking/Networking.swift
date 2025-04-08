//
//  Networking.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
internal import SwiftSoup

public enum NetworkingError: Error {
    case urlGenerationError
    case genericTypecastError
}

public struct Networking {
    /// A finite list of hitable endpoints
    public enum Endpoint {
        /// There are multiple profile pages on a single user's profile page
        public enum ProfilePages: String {
            /// Overview
            case dashboard
            
            /// User stats
            case profile
            
            /// All user written works
            case works
            
            /// All user written series
            case series
            
            /// All user bookmarked works
            case bookmarks
            
            /// A user curated collection of works
            case collections
            
            /// Stories written ("gifted") for this user
            case gifts
        }
        
        public enum Category: String {
            case anime = "Anime & Manga"
            case books = "Books & Literature"
            case tv = "TV Shows"
            case movies = "Movies"
            case games = "Video Games"
            case cartoons = "Cartoons & Comics & Graphic Novels"
            case celebrities = "Celebrities & Real People"
            case music = "Music & Bands"
            case theater = "Theater"
            case uncategorized = "Uncategorized Fandoms"
            case other = "Other Media"
        }
        
        /// All works related to a passed fandom or tag
        case relatedWorks(tag: String)
        
        /// A user's profile page. Use page .full to get a full look at the user's profile
        case profile(username: String, page: ProfilePages)
        
        /// All news articles from AO3
        case newsfeed
        
        /// A work chapter
        case work(work: Work, chapterID: String?)
        
        /// All chapters in a work (links)
        case workChapters(workID: String)
        
        /// All fandoms listed under a category
        case category(name: Category)
    }
    
    public static func fetch<T>(_ endpoint: Endpoint, at page: Int? = nil) async -> Result<T?, Error> {
        // Generate URL
        guard let url = generateURL(for: endpoint, at: page) else {
            return .failure(NetworkingError.urlGenerationError)
        }
        
        // Scrape webpage for raw HTML
        print("Fetching \(String(describing: url))")
        let result = await fetch(url: url)
        
        // Transform raw HTML into internal dataTypes
        switch result {
            case .success(let document):
                guard let value: T = await parseHTML(document: document, as: endpoint) else {
                    return .failure(NetworkingError.genericTypecastError)
                }
                
                return .success(value)
                
            case .failure(let error):
                return .failure(error)
        }
    }
    
    private static func fetch(url: URL) async -> Result<Document?, Error> {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let document = try SwiftSoup.parse(content)
            return .success(document)
        } catch let parsingError {
            print("Error fetching document: \(parsingError)")
            return .failure(parsingError)
        }
    }
    
    internal static func parseHTML<T>(document: Document?, as endpoint: Endpoint) async -> T? {
        switch endpoint {
            case .relatedWorks(let feedTitle):
                return FeedInfoFactory.parse(document, for: feedTitle) as? T
                
            case .profile(let username, let page):
                switch page {
                    case .profile:
                        return UserInfoFactory.parseProfile(document) as? T
                    default:
                        let profileInfo: UserInfo.ProfileInfo?
                        let chapterListResult: Result<UserInfo.ProfileInfo?, Error> = await fetch(.profile(username: username, page: .profile))
                        switch chapterListResult {
                            case .success(let profileInfoInternal):
                                profileInfo = profileInfoInternal
                            case .failure:
                                profileInfo = nil
                        }
                        guard let profileInfo = profileInfo else { return nil }
                        
                        return UserInfoFactory.parseDashboard(document, profileInfo: profileInfo) as? T
                }
                
            case .newsfeed:
                return await NewsFactory.parse(document) as? T
                
            case .work(let work, _):
                if work.shouldParseAdditionalInfo {
                    work.storyInfo = StoryInfoFactory.parse(document)
                    work.aboutInfo = AboutInfoFactory.parse(document)
                }
                
                if work.chapterList == nil {
                    let chapterListResult: Result<ChapterList?, Error> = await fetch(.workChapters(workID: work.id))
                    switch chapterListResult {
                        case .success(let chapterList):
                            work.chapterList = chapterList
                        case .failure:
                            break
                    }
                }
                
                guard let chapter = ChapterFactory.parse(document) else {
                    return work as? T
                }
                
                work.saveAsCurrentChapter(chapter)
                return work as? T
                
            case .workChapters:
                return ChapterListFactory.parse(document) as? T
                
            case .category:
                return CategoryInfoFactory.parse(document) as? T
        }
    }
}
                  
extension Networking {
    /// Generate a URL for the endpoint
    /// - Parameter endpoint: the desired webpage
    /// - Returns: a optional URL to the webpage
    internal static func generateURL(for endpoint: Endpoint, at page: Int? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "archiveofourown.org"
        
        switch endpoint {
            case .relatedWorks(let feedTitle):
                components.path = "/tags/\(feedTitle.webFriendly())/works"
            case .profile(let username, let page):
                let pageName: String = page == .dashboard ? "" : "/\(page)"
                components.path = "/users/\(username)\(pageName)"
            case .newsfeed:
                components.path = "/admin_posts"
            case .work(let work, let chapterID):
                let chapterInfo: String = chapterID == nil ? "" : "/chapters/\(chapterID!)"
                components.path = "/works/\(work.id)\(chapterInfo)"
                components.queryItems = [URLQueryItem(name: "view_adult", value: "true")]
            case .workChapters(let workID):
                components.path = "/works/\(workID)/navigate"
            case .category(let category):
                components.path = "/media/\(category.rawValue.webFriendly())/fandoms"
        }
        
        if let page = page {
            components.queryItems?.append(URLQueryItem(name: "page", value: String(page + 1)))
        }
        
        return components.url
    }
}
