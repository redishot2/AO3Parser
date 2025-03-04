//
//  UserInfoFactory.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
internal import SwiftSoup

internal class UserInfoFactory {
    
    internal static func parseDashboard(_ document: Document?, profileInfo: UserInfo.ProfileInfo) -> UserInfo? {
        guard let document = document else { return nil }
        guard let body = document.body() else { return nil }
        
        do {
            // Get to the area
            let main = try body.select("div").first(where: { $0.id() == "main" })
            let userHeader = try main?.select("div").first(where: { $0.hasClass("user home") })
            
            let fandoms = parseFandoms(userHeader)
            let works = parseWorks(userHeader)
            let series = parseSeries(userHeader)
            let bookmarks = parseBookmarks(userHeader)
            let counts = parseCounts(body)
            
            return UserInfo(profileInfo: profileInfo, counts: counts, fandoms: fandoms, recentWorks: works, recentSeries: series, recentBookmarks: bookmarks)
        } catch {
            return nil
        }
    }
    
    internal static func parseProfile(_ document: Document?) -> UserInfo.ProfileInfo? {
        guard let document = document else { return nil }
        guard let body = document.body() else { return nil }
        
        do {
            // Get to the area
            let pMain = try body.select("div").first(where: { $0.id() == "main" })
            let pUserHeader = try pMain?.select("div").first(where: { $0.hasClass("user home profile") })
            
            // Join date
            let joinMetaWrapper = try pUserHeader?.select("div").first(where: { $0.hasClass("wrapper") })
            let dateJoined = try joinMetaWrapper?.select("dd")[1].text()

            // Bio
            let bioWrapper = try pUserHeader?.select("div").first(where: { $0.hasClass("bio module") })
            let bio = try bioWrapper?.select("blockquote").first(where: { $0.hasClass("userstuff") })?.attributedText()
            
            // User name
            let headerModule = try pUserHeader?.select("div").first(where: { $0.hasClass("primary header module") })
            guard let username = try headerModule?.select("h2").first(where: { $0.hasClass("heading") })?.text() else { return nil }
            
            // Profile pic
            let iconMeta = try headerModule?.select("p").first(where: { $0.hasClass("icon") })
            let iconLinkMeta = try iconMeta?.select("a").first()
            let iconImageLinkMeta = try iconLinkMeta?.select("img").first()
            let profilePic = try iconImageLinkMeta?.attr("src")
            let profilePicURL = URL(string: profilePic ?? "")
            
            return UserInfo.ProfileInfo(username: username, profilePicture: profilePicURL, joinDate: dateJoined, bio: bio)
        } catch {
            return nil
        }
    }
    
    private static func parseUserSection(_ document: Element?, className: String, blurbClassName: String) -> [FeedCardInfo] {
        do {
            // Get to the area
            let worksList = try document?.select("div").first(where: { $0.hasClass(className) })
            
            guard let worksRaw = try worksList?.select("li").filter({
                let className = try $0.className()
                return className.contains(blurbClassName)
            }) else { return [] }
            
            return FeedInfoFactory.createFeedCardInfo(from: worksRaw)
        } catch {
            return []
        }
    }
    
    private static func parseWorks(_ document: Element?) -> [FeedCardInfo] {
        parseUserSection(document, className: "work listbox group", blurbClassName: "work blurb group work")
    }
    
    private static func parseSeries(_ document: Element?) -> [FeedCardInfo] {
        parseUserSection(document, className: "series listbox group", blurbClassName: "series blurb group series")
    }
    
    private static func parseBookmarks(_ document: Element?) -> [FeedCardInfo] {
        parseUserSection(document, className: "bookmark listbox group", blurbClassName: "bookmark blurb group work")
    }
    
    private static func parseFandoms(_ document: Element?) -> [LinkInfo] {
        do {
            // Get to the area
            let userHome = try document?.select("div").first(where: { $0.hasClass("user home") })
            let header = try userHome?.select("div").first(where: { $0.hasClass("fandom listbox group") })
            let fandomsList = try header?.select("ol").first(where: { $0.hasClass("index group") })
            guard let fandomsRaw = try fandomsList?.select("li") else { return [] }
            
            var links: [LinkInfo] = []
            for fandom in fandomsRaw {
                let text = try fandom.text()
                let url = try fandom.attr("href")
                
                links.append(LinkInfo(url: url, name: text))
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
