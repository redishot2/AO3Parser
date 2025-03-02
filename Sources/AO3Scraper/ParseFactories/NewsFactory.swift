//
//  NewsFactory.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
internal import SwiftSoup

internal class NewsFactory {
    
    internal static func parse(_ document: Document?) async -> News? {
        guard let document = document else { return nil }
        guard let body = document.body() else { return nil }
        
        do {
            let divs = try body.select("div")
            let outerDiv = try divs.select("div").first(where: { $0.id() == "outer" })
            let mainDiv = try outerDiv?.select("div").first(where: { $0.hasClass("news admin home") })
            let filtersDiv = try mainDiv?.select("ul").first(where: { $0.hasClass("navigation actions") })
            
            let tagDiv = try filtersDiv?.select("select").first(where: { $0.id() == "tag" })
            let tags = parseFilter(tagDiv)
            
            let translationsDiv = try filtersDiv?.select("select").first(where: { $0.id() == "language_id" })
            let translations = parseFilter(translationsDiv)
            
            let articlesDiv = try mainDiv?.select("div").filter({ $0.hasClass("news module group") })
            let articles = await parseArticles(articlesDiv)
            
            // Number of pages
            var pageCount = 0
            let navWrapper = try mainDiv?.select("ol").first(where: { $0.hasClass("pagination actions") })
            let buttonWrapper = try navWrapper?.select("li").last(where: { !$0.hasClass("next") })
            if let countRaw = try buttonWrapper?.text() {
                pageCount = countRaw.toInt() ?? 0
            }
            
            return News(articles: articles, tags: tags, translations: translations, pagesCount: pageCount)
        } catch {
            return nil
        }
    }
    
    private static func parseFilter(_ filter: Element?) -> [Link] {
        do {
            guard let options = try filter?.select("option") else { return [] }
             
            var filters: [Link] = []
            for item in options {
                let text = try item.text()
                let url = try item.attr("value")
                
                filters.append(Link(url: url, name: text))
            }
            
            return filters
        } catch {
            return []
        }
    }
    
    private static func parseArticles(_ articlesRaw: [Element]?) async -> [Article] {
        do {
            guard let articlesRaw = articlesRaw else { return [] }
             
            var articles: [Article] = []
            for item in articlesRaw {
                let titleRaw = try item.select("h3").first(where: { $0.hasClass("heading") })
                guard let title = try titleRaw?.text() else { continue }
                
                let headerRaw = try item.select("div").first(where: { $0.hasClass("wrapper") })
                
                guard let timeStamp = parseDate(headerRaw) else { continue }
                
                let tagsRaw = try item.select("ul").filter({ $0.hasClass("tags commas") }).first
                let tagsItems = try tagsRaw?.select("li")
                let tags = parseTagsList(tagsItems)
                
                let buttonsListRaw = try item.select("ul").first(where: { $0.hasClass("actions") })
                let buttonRaw = try buttonsListRaw?.select("li")
                let commentsURLRaw = try buttonRaw?.select("a")
                
                var commentURL: URL? = nil
                if let commentsURL = try commentsURLRaw?.attr("href") {
                    let fullURL = "https://archiveofourown.org" + commentsURL
                    if let commentsLink = URL(string: fullURL) {
                        commentURL = commentsLink
                    }
                }
                
                let actionsRaw = try item.select("ul").first(where: { $0.hasClass("actions") })?.select("a").first()
                let commentButtonText = try actionsRaw?.text().components(separatedBy: " ")
                var commentsCountRaw: String? = nil
                if commentButtonText?.count ?? 0 > 2 {
                    commentsCountRaw = commentButtonText?[1]
                }
                let commentsCount = commentsCountRaw?.toInt() ?? 0
                
                var text: [Article.Content] = []
                if let articleRaw = try item.select("div").first(where: { $0.hasClass("userstuff") }) {
                    text = parseArticleContent(articleRaw)
                }
                
                let article = Article(title: title, timeStamp: timeStamp, tags: tags, commentURL: commentURL, commentsCount: commentsCount, text: text)
                articles.append(article)
            }
            
            return articles
        } catch {
            return []
        }
    }
    
    static func parseArticleComments(using document: Document?) async -> [Article.Comment] {
        var comments: [Article.Comment] = []
        
        guard let document = document else { return comments }
        guard let body = document.body() else { return comments }
        
        do {
            let divs = try body.select("div")
            let outerDiv = try divs.select("div").first(where: { $0.id() == "outer" })
            let mainDiv = try outerDiv?.select("div").first(where: { $0.hasClass("news admin home") })
            let feedbackDiv = try mainDiv?.select("div").first(where: { $0.id() == "feedback" })
            let commentsDiv = try feedbackDiv?.select("div").first(where: { $0.id() == "comments_placeholder" })
            
            comments = parseThread(commentsDiv)
            
            return comments
        } catch {
            return comments
        }
    }
    
    private static func parseThread(_ commentGroup: Element?, replyingTo: String? = nil) -> [Article.Comment] {
        var comments: [Article.Comment] = []
        
        do {
            guard let commentsList = try commentGroup?.select("ol").first(where: { $0.hasClass("thread") })?.children() else {
                return comments
            }
            
            for commentRaw in commentsList {
                if try !commentRaw.className().isEmpty {
                    // Parse comment
                    if let comment = parseComment(commentRaw, replyingTo: replyingTo) {
                        comments.append(comment)
                    }
                } else {
                    // Sub comments
                    let subComments = parseThread(commentRaw, replyingTo: comments.last?.username.url)
                    guard !subComments.isEmpty else { continue }
                    
                    if replyingTo == nil {
                        comments[comments.count - 1].childComments.append(contentsOf: subComments)
                    } else {
                        comments.append(contentsOf: subComments)
                    }
                }
            }
            
            return comments
        } catch {
            return comments
        }
    }
    
    private static func parseComment(_ commentRaw: Element?, replyingTo: String?) -> Article.Comment? {
        do {
            let headerRaw = try commentRaw?.select("h4").first(where: { $0.hasClass("heading byline") })
            
            // Profile
            let profileRaw = try headerRaw?.select("a").first()
            guard let profileURLRaw = try profileRaw?.attr("href") else { return nil }
            guard let profileName = try profileRaw?.text() else { return nil }
            let profileURL = profileURLRaw.components(separatedBy: "/")
            guard profileURL.count > 2 else { return nil }
            let username = Link(url: profileURL[2], name: profileName)
            
            // Verified
            let verifiedRaw = try headerRaw?.select("span").first(where: { $0.hasClass("role") })
            let isVerified = verifiedRaw != nil
            
            // Timestamp
            let postedRaw = try headerRaw?.select("span").first()
            let postedTimestamp = parseCommentDate(postedRaw)
            
            // Profile Picture
            let pictureDivRaw = try commentRaw?.select("div").first(where: { $0.hasClass("icon") })
            let pictureRaw = try pictureDivRaw?.select("a").first()?.select("img").first()
            var profilePicture: URL?
            if let url = try pictureRaw?.attr("src") {
                profilePicture = URL(string: url)
            }
            
            // Edited timestamp
            let editedRaw = try commentRaw?.select("p").first(where: { $0.hasClass("edited datetime") })
            let editedTimestamp = parseCommentDate(editedRaw)
            
            // Comment text
            let commentBlockRaw = try commentRaw?.select("blockquote").first(where: { $0.hasClass("userstuff") })
            var comment = ""
            let _ = try commentBlockRaw?.select("p").map({ comment += try $0.text() })
            
            return Article.Comment(
                username: username,
                profilePicture: profilePicture,
                isVerified: isVerified,
                commentText: comment,
                timestamp: postedTimestamp ?? "",
                editedTimestamp: editedTimestamp,
                replyingTo: replyingTo,
                childComments: []
            )
        } catch {
            return nil
        }
    }
    
    private static func parseCommentDate(_ dateRaw: Element?) -> String? {
        do {
            guard
                let day   = try dateRaw?.select("span").first(where: { $0.hasClass("date") })?.text(),
                let month = try dateRaw?.select("abbr").first(where: { $0.hasClass("month") })?.text(),
                let year  = try dateRaw?.select("span").first(where: { $0.hasClass("year") })?.text()
            else {
                return nil
            }
            
            let timestamp = month + " " + day + ", " + year
            return timestamp
        } catch {
            return nil
        }
    }
    
    private static func parseDate(_ dateWrapper: Element?) -> Date? {
        do {
            guard
                let dateRaw = try dateWrapper?.select("dd").first(where: { $0.hasClass("published") })?.text()
            else { return nil }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
            guard let publishedDate = dateFormatter.date(from: dateRaw) else { return nil }
        
            return publishedDate
        } catch {
            return nil
        }
    }
    
    private static func parseTagsList(_ wrapper: Elements?) -> [Link] {
        do {
            var links: [Link] = []
            
            guard let wrapper = wrapper else {
                return links
            }
            
            for item in wrapper {
                let text = try item.text()
                if let linkRaw = try item.select("a").first() {
                    let url = try linkRaw.attr("href")
                    let tagID = String(url.split(separator: "=")[1])
                    
                    links.append(Link(url: tagID, name: text))
                }
            }
            
            return links
        } catch {
            return []
        }
    }
    
    private static func parseArticleContent(_ wrapper: Element) -> [Article.Content] {
        do {
            var content: [Article.Content] = []
            
            for item in wrapper.children() {
                
                switch item.tagName() {
                    case "hr":
                        content.append(Article.Content.divider)
                    case "h1":
                        content.append(Article.Content.header(text: try item.text(), size: .h1))
                    case "h2":
                        content.append(Article.Content.header(text: try item.text(), size: .h2))
                    case "h3":
                        content.append(Article.Content.header(text: try item.text(), size: .h3))
                    case "h4":
                        content.append(Article.Content.header(text: try item.text(), size: .h4))
                    case "h5":
                        content.append(Article.Content.header(text: try item.text(), size: .h5))
                    case "h6":
                        content.append(Article.Content.header(text: try item.text(), size: .h6))
                    case "ul": fallthrough
                    case "ol":
                        var list: [AttributedString] = []
                        for listItem in try item.select("li") {
                            guard let text = listItem.attributedText() else {
                                print("Failed to convert list item:\n\(listItem)")
                                continue
                            }
                            list.append(text)
                        }
                        content.append(Article.Content.list(items: list))
                    case "p": fallthrough
                    case "center":
                        if let image = try item.select("img").first() {
                            let src = try image.attr("src")
                            content.append(Article.Content.image(url: src))
                        } else {
                            guard let paragraph = item.attributedText() else {
                                print("Failed to convert text into paragraph:\n\(item)")
                                continue
                            }
                            content.append(Article.Content.paragraph(text: paragraph))
                        }
                    default:
                        print("WARNING: uncaught article content type '\(item.tagName())'")
                }
            }
            
            if content.count != wrapper.children().count {
                print("WARNING: article content parsing does not match expected items")
            }
            
            return content
        } catch {
            return []
        }
    }
}
