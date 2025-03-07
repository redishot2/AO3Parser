//
//  ChapterListFactory.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
internal import SwiftSoup

internal class ChapterListFactory {
    
    internal static func parse(_ document: Document?) -> ChapterList? {
        guard let document = document else { return nil }
        guard let metaItems = ChapterListFactory.getToChapterListData(document) else { return nil }
        
        var chapterLists: [String] = []
        do {
            for chapterLink in metaItems {
                let link = try chapterLink.select("a").first()
                if let linkHref = try link?.attr("href"), let linkText = try link?.text() {
                    let components = linkHref.components(separatedBy: "/")
                    if let _ = components.last {
                        chapterLists.append(linkText)
                    }
                }
            }
        } catch {
            return nil
        }
        
        return ChapterList(chapters: chapterLists)
    }
    
    private static func getToChapterListData(_ document: Document) -> Elements? {
        guard let body = document.body() else { return nil }
        do {
            let divs = try body.select("div")
            let divOuter = divs.first(where: { $0.id() == "outer" })
            let divInner = try divOuter?.select("div").first(where: { $0.id() == "inner" })
            let divMain = try divInner?.select("div").first(where: { $0.id() == "main" })
            let chapterList = try divMain?.select("ol").first(where: { $0.hasClass("chapter index group") })
            let chapterLinks = try chapterList?.select("li")
            
            return chapterLinks
        } catch {
            return nil
        }
    }
}
