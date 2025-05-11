//
//  FeedInfoFactory.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
internal import SwiftSoup
import SwiftUI

internal class FeedInfoFactory {
    
    internal static func parse(_ document: Document?, for feedTitle: String) -> FeedInfo? {
        guard let body = document?.body() else { return nil }
        do {
            let divs = try body.select("div")
            let div = divs.first(where: { $0.id() == "outer" })
            let divWrapper = try div?.select("div").first(where: { $0.id() == "main" })
            let metaItems = try divWrapper?.select("ol").first(where: { $0.hasClass("work index group") })
            
            // Number of pages
            var pageCount = 0
            let navWrapper = try divWrapper?.select("ol").first(where: { $0.hasClass("pagination actions pagy") })
            let buttonWrapper = try navWrapper?.select("li").last(where: { !$0.hasClass("next") })
            if let countRaw = try buttonWrapper?.text() {
                pageCount = countRaw.toInt() ?? 0
            }
            
            // Feed
            guard let feedItems = try metaItems?.select("li").filter({
                let className = try $0.className()
                return className.contains("work blurb group work")
            }) else { return nil }
            
            // Filter
            let filter = createFilter(from: divWrapper, fandomName: feedTitle) ?? FeedFilterInfo.empty(fandom: feedTitle)
            
            return FeedInfo(feedInfo: createFeedCardInfo(from: feedItems), pagesCount: pageCount, filter: filter)
        } catch {
            return nil
        }
    }
    
    static func createFeedCardInfo(from workCard: [Element]) -> [FeedCardInfo] {
        
        var cards: [FeedCardInfo] = []
        for workCard in workCard {
            if let card = createFeedCardInfo(from: workCard) {
                cards.append(card)
            }
        }
        
        return cards
    }
    
    private static func createFeedCardInfo(from workCard: Element) -> FeedCardInfo? {
        do {
            // Work ID
            let workIDRaw = workCard.id()
            let workID = workIDRaw.replacingOccurrences(of: "work_", with: "")
            
            // Work info
            let header = try workCard.select("div").first(where: { $0.hasClass("header module") })
            let heading = try header?.select("h4").first(where: { $0.hasClass("heading") })
            let workTitle = try heading?.select("a")[0].text()
            guard let authorRaw = try heading?.select("a"), authorRaw.count > 1 else { return nil }
            var authors: [String] = []
            for author in authorRaw {
                let authorName = try author.text()
                authors.append(authorName)
            }
            let lastUpdated = try header?.select("p").first(where: { $0.hasClass("datetime") })?.text()
            
            // Rating
            let requiredTags = try header?.select("ul").first(where: { $0.hasClass("required-tags") })
            let requiredTags2 = try requiredTags?.select("li").first()
            let requiredTags3 = try requiredTags2?.select("a").first()
            let requiredTags4 = try requiredTags3?.select("span").first()
            let rawRating = try requiredTags4?.select("span").first()?.text()
            let rating = StoryInfo.Rating(rawValue: rawRating ?? "")
            
            // Categories
            let categoryTagWrapper = try requiredTags?.select("li")[2]
            var category: StoryInfo.Category? = nil
            if let categoryText = try categoryTagWrapper?.select("span").first(where: { $0.hasClass("text") })?.text() {
                category = StoryInfo.Category(rawValue: categoryText)
            }
            
            // Fandoms
            var fandoms: [String] = []
            if let worksContainer = try header?.select("h5").first(where: { $0.hasClass("fandoms heading") }) {
                let workLinks = try worksContainer.select("a")
                for workLink in workLinks {
                    let fandom = try workLink.text()
                    fandoms.append(fandom)
                }
            }
            
            // Tags
            let tagsContainer = try workCard.select("ul").first(where: { $0.hasClass("tags commas") })
            let relationshipsWrapper = try tagsContainer?.select("li").filter({ $0.hasClass("relationships") })
            let relationships = createTagsArray(from: relationshipsWrapper)
            let charactersWrapper = try tagsContainer?.select("li").filter({ $0.hasClass("characters") })
            let characters = createTagsArray(from: charactersWrapper)
            let freeformsWrapper = try tagsContainer?.select("li").filter({ $0.hasClass("freeforms") })
            let freeforms = createTagsArray(from: freeformsWrapper)
            
            // Warnings
            let warningsWrapper = try tagsContainer?.select("li").filter({ $0.hasClass("warnings") })
            var warnings: [StoryInfo.Warning] = []
            let strongWrapper = try warningsWrapper?.first?.select("strong").first()
            if let wrapper = try strongWrapper?.select("a") {
                for warningWrapper in wrapper {
                    let warningRaw = try warningWrapper.text()
                    if let warning = StoryInfo.Warning(rawValue: warningRaw) {
                        warnings.append(warning)
                    }
                }
            }
            
            // Summary
            let summaryWrapper = try workCard.select("blockquote").first(where: { $0.hasClass("userstuff summary") })
            let summary = summaryWrapper?.attributedText()
            
            // Stats
            let statsHeader = try workCard.select("dl").first(where: { $0.hasClass("stats") })
            let language = try statsHeader?.select("dd").first(where: { $0.hasClass("language") })?.text()
            
            let words = try statsHeader?.select("dd").first(where: { $0.hasClass("words") })?.text()
            let kudos = try statsHeader?.select("dd").first(where: { $0.hasClass("kudos") })?.text()
            let bookmarks = try statsHeader?.select("dd").first(where: { $0.hasClass("bookmarks") })?.text()
            let hits = try statsHeader?.select("dd").first(where: { $0.hasClass("hits") })?.text()
            
            let chaptersWrapper = try statsHeader?.select("dd").first(where: { $0.hasClass("chapters") })
            let chapters = try chaptersWrapper?.text()
            
            let commentsWrapper = try statsHeader?.select("dd").first(where: { $0.hasClass("comments") })
            let comments = try commentsWrapper?.text()
            
            let stats = FeedCardInfo.Stats(lastUpdated: lastUpdated, words: words, chapters: chapters, comments: comments, kudos: kudos, bookmarks: bookmarks, hits: hits, language: language)
            
            let tags = FeedCardInfo.Tags(warnings: warnings, category: category, fandoms: fandoms, relationships: relationships, characters: characters, tags: freeforms, collections: [])
            
            return FeedCardInfo(title: workTitle, workID: workID, authors: authors, summary: summary, rating: rating, tags: tags, stats: stats)
        } catch {
            return nil
        }
    }
    
    private static func createTagsArray(from elements: [Element]?) -> [String] {
        guard let elements = elements else { return [] }

        do {
            var fandoms: [String] = []
            for workLinks in elements {
                let work = try workLinks.select("a")
                for workLink in work {
                    let fandom = try workLink.text()
                    fandoms.append(fandom)
                }
            }
            
            return fandoms
        } catch {
            return []
        }
    }
    
    private static func createFilter(from elements: Element?, fandomName: String) -> FeedFilterInfo? {
        guard let elements = elements else { return nil }

        do {
            let header = try elements.select("form").first(where: { $0.hasClass("narrow-hidden filters") })
            let form = try header?.select("fieldset").first()?.select("dl").first()
            let includeFilters = try form?.select("dd").first(where: { $0.hasClass("include tags group") })
            
            let rawRating = try includeFilters?.select("dd")
                .first(where: { $0.id() == "include_rating_tags" })
            let ratings = createFilterItem(from: rawRating)
            
            let rawWarning = try includeFilters?.select("dd")
                .first(where: { $0.id() == "include_archive_warning_tags" })
            let warnings = createFilterItem(from: rawWarning)
            
            let rawCategory = try includeFilters?.select("dd")
                .first(where: { $0.id() == "include_category_tags" })
            let categories = createFilterItem(from: rawCategory)
            
            let rawCharacters = try includeFilters?.select("dd")
                .first(where: { $0.id() == "include_character_tags" })
            let characters = createFilterItem(from: rawCharacters)
            
            let rawRelationships = try includeFilters?.select("dd")
                .first(where: { $0.id() == "include_relationship_tags" })
            let relationships = createFilterItem(from: rawRelationships)
            
            let rawFandoms = try includeFilters?.select("dd")
                .first(where: { $0.id() == "include_fandom_tags" })
            let fandoms = createFilterItem(from: rawFandoms)
            
            let rawAdditionalTags = try includeFilters?.select("dd")
                .first(where: { $0.id() == "include_freeform_tags" })
            let additionalTags = createFilterItem(from: rawAdditionalTags)
            
            let moreOptionsFilters = try form?.select("dd").first(where: { $0.hasClass("more group") })
            let languageRaw = try moreOptionsFilters?.select("dd")
                .first(where: { try $0.className() == "language" })
            let languagesWrapperRaw = try languageRaw?.select("select").first()
            let languages = createLanguages(from: languagesWrapperRaw)
            
            return FeedFilterInfo(fandomName: fandomName, ratings: ratings, warnings: warnings, categories: categories, fandoms: fandoms, characters: characters, relationships: relationships, additionalTags: additionalTags, languages: languages)
        } catch {
            return nil
        }
    }
    
    private static func createFilterItem(from elements: Element?) -> [FeedFilterInfo.FilterInfo] {
        var filter: [FeedFilterInfo.FilterInfo] = []
        
        do {
            guard let filterElements = try elements?.select("li") else { return filter }
            
            for element in filterElements {
                let idValue = try element.select("input").val()
                let name = try element.select("span").first(where: { !$0.hasClass("indicator") })?.text() ?? ""
                
                filter.append(FeedFilterInfo.FilterInfo(name: name, id: idValue))
            }
        } catch {
            return filter
        }
        
        return filter
    }
    
    private static func createLanguages(from elements: Element?) -> [FeedFilterInfo.FilterInfo] {
        var filter: [FeedFilterInfo.FilterInfo] = []
        
        do {
            guard let filterElements = try elements?.select("option") else { return filter }
            
            for element in filterElements {
                let name = try element.text()
                let idValue = try element.val()
                
                filter.append(FeedFilterInfo.FilterInfo(name: name, id: idValue))
            }
        } catch {
            return filter
        }
        
        return filter
    }
}
