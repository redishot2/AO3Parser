//
//  AboutInfoFactory.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
internal import SwiftSoup

internal class AboutInfoFactory {
    
    internal static func parse(_ document: Document?) -> AboutInfo? {
        guard let document = document else { return nil }
        guard let metaItems = AboutInfoFactory.getToAboutInfoData(document) else { return nil }
        
        do {
            // Title
            let rawTitle = try metaItems.select("h2").first(where: { $0.hasClass("title heading") })
            guard let title = try rawTitle?.text() else { return nil }
            
            // Author
            var authors: [String] = []
            let authorWrapper = try metaItems.select("h3").first(where: { $0.hasClass("byline heading") })
            if let authorsRaw = try authorWrapper?.select("a") {
                for author in authorsRaw {
                    let authorName = try author.text()
                    authors.append(authorName)
                }
            } else {
                return nil
            }

            // Summary
            let summaryWrapper = try metaItems.select("div").first(where: { $0.hasClass("summary module") })
            let summaryRaw = try summaryWrapper?.select("blockquote")
            guard let summary = summaryRaw?.attributedText() else { return nil }
            
            return AboutInfo(title: title, authors: authors, summary: summary)
        } catch {
            return nil
        }
    }
    
    private static func getToAboutInfoData(_ document: Document) -> Element? {
        guard let body = document.body() else { return nil }
        do {
            let divs = try body.select("div")
            let div = divs.first(where: { $0.id() == "outer" })
            let divWrapper = try div?.select("div").first(where: { $0.id() == "workskin" })
            let metaItems = try divWrapper?.select("div").first(where: { $0.hasClass("preface group") })
            
            return metaItems
        } catch {
            return nil
        }
    }
}
