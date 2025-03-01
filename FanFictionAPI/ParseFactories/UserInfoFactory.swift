//
//  UserInfoFactory.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
internal import SwiftSoup

internal class UserInfoFactory {
    
    internal static func parse(_ document: Document?) -> UserInfo? {
        guard let document = document else { return nil }
        guard let body = document.body() else { return nil }
        
        do {
            // Get to the area
            let main = try body.select("div").first(where: { $0.id() == "main" })
            let userHeader = try main?.select("div").first(where: { $0.hasClass("user home") })
            
            let fandoms = parseFandoms(userHeader)
            let profile = parseProfile(userHeader)
            let works = parseWorks(userHeader)
            let series = parseSeries(userHeader)
            let bookmarks = parseBookmarks(userHeader)
            let gifts = parseGifts(userHeader)
            let counts = parseCounts(body)
            
            // TODO: fix
            var userInfo: (joinDate: String?, bio: AttributedString?) = (nil, nil)
//            if let profileDoc = profileDoc, let profileDoc2 = profileDoc, let profileBody = profileDoc2.body() {
//                let pMain = try profileBody.select("div").first(where: { $0.id() == "main" })
//                let pUserHeader = try pMain?.select("div").first(where: { $0.hasClass("user home profile") })
//                userInfo = parseUserInfo(pUserHeader)
//            }
            
            return UserInfo(username: profile.username, profilePicture: profile.picture, joinDate: userInfo.joinDate, bio: userInfo.bio, counts: counts, fandoms: fandoms, recentWorks: works, recentSeries: series, recentBookmarks: bookmarks)
        } catch {
            return nil
        }
    }
    
    private static func parseProfile(_ document: Element?) -> (username: String, picture: URL?) {
        do {
            // Profile pic
            let headerModule = try document?.select("div").first(where: { $0.hasClass("primary header module") })
            let username = try headerModule?.select("h2").first(where: { $0.hasClass("heading") })?.text() ?? ""
            let iconMeta = try headerModule?.select("p").first(where: { $0.hasClass("icon") })
            let iconLinkMeta = try iconMeta?.select("a").first()
            let iconImageLinkMeta = try iconLinkMeta?.select("img").first()
            let profilePic = try iconImageLinkMeta?.attr("src")
            let profilePicURL = URL(string: profilePic ?? "")
            
            return (username, profilePicURL)
        } catch {
            return ("", nil)
        }
    }
    
    // TODO: fix
//    private static func parseUserInfo(_ document: Element?) -> (joinDate: String?, bio: AttributedString?) {
//        do {
//            // Join date
//            let joinMetaWrapper = try document?.select("div").first(where: { $0.hasClass("wrapper") })
//            let dateJoined = try joinMetaWrapper?.select("dd")[1].text()
//
//            // Bio
//            let bioWrapper = try document?.select("div").first(where: { $0.hasClass("bio module") })
//            let bio = try bioWrapper?.select("blockquote").first(where: { $0.hasClass("userstuff") })?.attributedText()
//            
//            return (dateJoined, bio)
//        } catch {
//            return ("", nil)
//        }
//    }
    
    private static func parseWorks(_ document: Element?) -> [FeedCardInfo] {
        do {
            // Get to the area
            let worksList = try document?.select("div").first(where: { $0.hasClass("work listbox group") })
            
            guard let worksRaw = try worksList?.select("li").filter({
                let className = try $0.className()
                return className.contains("work blurb group work")
            }) else { return [] }
            
            return FeedInfoFactory.createFeedCardInfo(from: worksRaw)
        } catch {
            return []
        }
    }
    
    private static func parseSeries(_ document: Element?) -> [FeedCardInfo] {
        do {
            // Get to the area
            let worksList = try document?.select("div").first(where: { $0.hasClass("series listbox group") })
            guard let worksRaw = try worksList?.select("li").filter({
                let className = try $0.className()
                return className.contains("series blurb group series")
            }) else { return [] }
            
            return FeedInfoFactory.createFeedCardInfo(from: worksRaw)
        } catch {
            return []
        }
    }
    
    private static func parseBookmarks(_ document: Element?) -> [FeedCardInfo] {
        do {
            // Get to the area
            let worksList = try document?.select("div").first(where: { $0.hasClass("bookmark listbox group") })
            guard let worksRaw = try worksList?.select("li").filter({
                let className = try $0.className()
                return className.contains("bookmark blurb group work")
            }) else { return [] }
            
            return FeedInfoFactory.createFeedCardInfo(from: worksRaw)
        } catch {
            return []
        }
    }
    
    private static func parseGifts(_ document: Element?) -> [FeedCardInfo] {
        do {
            // Get to the area
            let worksList = try document?.select("ul").first(where: { $0.hasClass("gift work index group") })
            
            guard let worksRaw = try worksList?.select("li").filter({
                let className = try $0.className()
                return className.contains("gift work blurb group work")
            }) else { return [] }
            
            return FeedInfoFactory.createFeedCardInfo(from: worksRaw)
        } catch {
            return []
        }
    }
    
    private static func parseFandoms(_ document: Element?) -> [Link] {
        do {
            // Get to the area
            let userHome = try document?.select("div").first(where: { $0.hasClass("user home") })
            let header = try userHome?.select("div").first(where: { $0.hasClass("fandom listbox group") })
            let fandomsList = try header?.select("ol").first(where: { $0.hasClass("index group") })
            guard let fandomsRaw = try fandomsList?.select("li") else { return [] }
            
            var links: [Link] = []
            for fandom in fandomsRaw {
                let text = try fandom.text()
                let url = try fandom.attr("href")
                
                links.append(Link(url: url, name: text))
            }
            
            return links
        } catch {
            return []
        }
    }
    
    private static func parseCounts(_ document: Element?) -> UserInfo.Counts {
        do {
            // Get to the area
            let dashboard = try document?.select("div").first(where: { $0.id() == "dashboard" })
            let header = try dashboard?.select("ul").filter({ $0.hasClass("navigation actions") })[1]
            
            let workCount        = try header?.select("li")[0].text().slice(from: "(", to: ")")
            let seriesCount      = try header?.select("li")[1].text().slice(from: "(", to: ")")
            let bookmarksCount   = try header?.select("li")[2].text().slice(from: "(", to: ")")
            let collectionsCount = try header?.select("li")[3].text().slice(from: "(", to: ")")
            
            let work        = workCount?.toInt() ?? 0
            let series      = seriesCount?.toInt() ?? 0
            let bookmarks   = bookmarksCount?.toInt() ?? 0
            let collections = collectionsCount?.toInt() ?? 0
            
            return UserInfo.Counts(works: work, series: series, bookmarks: bookmarks, collections: collections)
        } catch {
            return UserInfo.Counts(works: 0, series: 0, bookmarks: 0, collections: 0)
        }
    }
}
