//
//  StoryInfoFactory.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
internal import SwiftSoup

internal class StoryInfoFactory {
    
    internal static func createChapterStoryInfo(using document: Document?) -> StoryInfo? {
        guard let document = document else { return nil }
        guard let metaItems = StoryInfoFactory.getToStoryInfoData(document) else { return nil }
        
        do {
            // Rating
            guard let ratingRaw = metaItems.first(where: { $0.hasClass("rating tags") }) else { return nil }
            let ratingValues = getRawListValues(ratingRaw)
            guard let rating = StoryInfo.Rating(rawValue: ratingValues.first?.name ?? "") else { return nil }
            
            // Warnings
            guard let warningsRaw = metaItems.first(where: { $0.hasClass("warning tags") }) else { return nil }
            let warningsValues = getRawListValues(warningsRaw)
            var warnings: [StoryInfo.Warning] = []
            for warningRaw in warningsValues {
                guard let warning = StoryInfo.Warning(rawValue: warningRaw.name) else { continue }
                warnings.append(warning)
            }
            
            // Categories
            guard let categoriesRaw = metaItems.first(where: { $0.hasClass("category tags") }) else { return nil }
            let categoriesValues = getRawListValues(categoriesRaw)
            var categories: [StoryInfo.Category] = []
            for categoryRaw in categoriesValues {
                guard let category = StoryInfo.Category(rawValue: categoryRaw.name) else { continue }
                categories.append(category)
            }
            
            // Fandoms
            guard let fandomsRaw = metaItems.first(where: { $0.hasClass("fandom tags") }) else { return nil }
            let fandoms = getRawListValues(fandomsRaw)
            
            // Relationships
            guard let relationshipRaw = metaItems.first(where: { $0.hasClass("relationship tags") }) else { return nil }
            let relationships = getRawListValues(relationshipRaw)
            
            // Characters
            guard let characterRaw = metaItems.first(where: { $0.hasClass("character tags") }) else { return nil }
            let characters = getRawListValues(characterRaw)
            
            // Additional Tags
            guard let tagsRaw = metaItems.first(where: { $0.hasClass("freeform tags") }) else { return nil }
            let tags = getRawListValues(tagsRaw)
            
            // Language
            guard let languageRaw = metaItems.first(where: { $0.hasClass("language") }) else { return nil }
            let language = try languageRaw.text()
            
            // Collections
            guard let collectionsRaw = metaItems.first(where: { $0.hasClass("collections") }) else { return nil }
            let collectionsHTML = try collectionsRaw.select("a")
            var collections: [Link] = []
            for collectionRaw in collectionsHTML {
                let collectionLink = try collectionRaw.attr("href")
                let collectionText = try collectionRaw.text()
                collections.append(Link(url: collectionLink, name: collectionText))
            }
            
            // Stats
            guard let statsRaw = metaItems.first(where: { $0.hasClass("stats") }) else { return nil }
            guard let stats = getStats(from: statsRaw) else { return nil }
            
            return StoryInfo(rating: rating, warnings: warnings, categories: categories, fandoms: fandoms, relationships: relationships, characters: characters, tags: tags, language: language, collections: collections, stats: stats)
        } catch {
            return nil
        }
    }
    
    private static func getToStoryInfoData(_ document: Document) -> Elements? {
        guard let body = document.body() else { return nil }
        do {
            let divs = try body.select("div")
            let div = divs.first(where: { $0.id() == "outer" })
            let divWrapper = try div?.select("div").first(where: { $0.hasClass("wrapper") })
            let metaDivs = try divWrapper?.select("dl").first(where: { $0.hasClass("work meta group") })
            let metaItems = try metaDivs?.select("dd")
            
            return metaItems
        } catch {
            return nil
        }
    }
    
    public static func getStats(from statsRaw: Element) -> StoryInfo.Stats? {
        do {
            let statsGroup = try statsRaw.select("dl")
            let statsList = try statsGroup.select("dd")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            // Published Date
            guard let publishedDateRaw = statsList.first(where: { $0.hasClass("published") }) else { return nil }
            let publishedDateString = try publishedDateRaw.text()
            guard let publishedDate = dateFormatter.date(from: publishedDateString) else { return nil }
            
            // Completed Date
            var completedDate: Date?
            if let completedDateRaw = statsList.first(where: { $0.hasClass("status") }) {
                let completedDateString = try completedDateRaw.text()
                if let completedDateL = dateFormatter.date(from: completedDateString) {
                    completedDate = completedDateL
                }
            }
            
            // Word Count
            guard let wordsRaw = statsList.first(where: { $0.hasClass("words") }) else { return nil }
            let wordsCountString = try wordsRaw.text()
            guard let wordCount = Int(wordsCountString) else { return nil }
            
            // Chapters
            guard let chaptersRaw = statsList.first(where: { $0.hasClass("chapters") }) else { return nil }
            let chapters = try chaptersRaw.text()
            
            // Comment Count
            guard let commentsRaw = statsList.first(where: { $0.hasClass("comments") }) else { return nil }
            let commentsCountString = try commentsRaw.text()
            guard let comments = Int(commentsCountString) else { return nil }
            
            // Kudos Count
            guard let kudosRaw = statsList.first(where: { $0.hasClass("kudos") }) else { return nil }
            let kudosCountString = try kudosRaw.text()
            guard let kudos = Int(kudosCountString) else { return nil }
            
            // Bookmarks Count
            guard let bookmarksRaw = statsList.first(where: { $0.hasClass("bookmarks") }) else { return nil }
            let bookmarksString = try bookmarksRaw.text()
            guard let bookmarks = Int(bookmarksString) else { return nil }
            
            // Hits Count
            guard let hitsRaw = statsList.first(where: { $0.hasClass("hits") }) else { return nil }
            let hitsCountString = try hitsRaw.text()
            guard let hits = Int(hitsCountString) else { return nil }
            
            return StoryInfo.Stats(published: publishedDate, completed: completedDate, words: wordCount, chapters: chapters, comments: comments, kudos: kudos, bookmarks: bookmarks, hits: hits)
        } catch {
            return nil
        }
    }
    
    private static func getRawListValues(_ element: Element) -> [Link] {
        do {
            let list = try element.select("ul").first()
            guard let items = try list?.select("li") else { return [] }
            
            var returnItems: [Link] = []
            for item in items {
                let linkRaw = item.child(0)
                let linkHref: String = try linkRaw.attr("href")
                let linkText: String = try linkRaw.text()
                
                returnItems.append(Link(url: linkHref, name: linkText))
            }
            
            return returnItems
        } catch {
            return []
        }
    }
}
