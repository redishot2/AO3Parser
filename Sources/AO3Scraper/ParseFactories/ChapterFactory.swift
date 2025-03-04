//
//  ChapterFactory.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
internal import SwiftSoup
import SwiftUI

internal class ChapterFactory {
    
    internal static func parse(_ document: Document?) -> Chapter? {
        guard let document = document else { return nil }
        guard let metaItems = ChapterFactory.getToChapterData(document) else { return nil }
        
        do {
            // Chapter Title
            let chapterTitleWrapper = try metaItems.select("div").first(where: { $0.hasClass("chapter preface group") })
            let chapterRaw = try chapterTitleWrapper?.select("h3").first(where: { $0.hasClass("title") })
            let chapterLinkRaw = try chapterRaw?.select("a").first()
            guard let chapterLink = try chapterLinkRaw?.attr("href") else { return nil }
            guard let chapterTitle = try chapterRaw?.text() else { return nil }
            let title = LinkInfo(url: chapterLink, name: chapterTitle)
            
            // Pre Chapter Notes
            let preNotesWrapper = try metaItems.select("div").first(where: { $0.hasClass("notes module") })
            let preNotesRaw = try preNotesWrapper?.select("blockquote").first(where: { $0.hasClass("userstuff") })
            var preNotes: [ChapterParagraph] = []
            if let preNotesItemsRaw = try preNotesRaw?.select("p") {
                preNotes = parseParagraphs(preNotesItemsRaw)
            }
            
            // Chapter Contents
            let chapters = try metaItems.select("div").first(where: { $0.hasClass("userstuff module") })
            guard let chapterItemsRaw = try chapters?.select("p") else { return nil }
            let paragraphs = parseParagraphs(chapterItemsRaw)
            
            // Pre Chapter Notes
            let postNotesWrapper = try metaItems.select("div").first(where: { $0.hasClass("end notes module") })
            let postNotesRaw = try postNotesWrapper?.select("blockquote").first(where: { $0.hasClass("userstuff") })
            var postNotes: [ChapterParagraph] = []
            if let postNotesItemsRaw = try postNotesRaw?.select("p") {
                postNotes = parseParagraphs(postNotesItemsRaw)
            }
            
            return Chapter(title: title, paragraphs: paragraphs, preNotes: preNotes, postNotes: postNotes)
        } catch {
            return nil
        }
    }
    
    private static func getToChapterData(_ document: Document) -> Element? {
        guard let body = document.body() else { return nil }
        do {
            let divs = try body.select("div")
            let div = divs.first(where: { $0.id() == "outer" })
            let divWrapper = try div?.select("div").first(where: { $0.id() == "workskin" })
            let chapters = try divWrapper?.select("div").first(where: { $0.id() == "chapters" })
            let chapter = try chapters?.select("div").first(where: { $0.hasClass("chapter") })
            
            return chapter ?? chapters
        } catch {
            return nil
        }
    }
    
    private static func parseParagraphs(_ elements: Elements) -> [ChapterParagraph] {
        var paragraphs: [ChapterParagraph] = []
        for element in elements {
            paragraphs.append(contentsOf: parseParagraph(element))
        }
        
        return paragraphs
    }
    
    private static func parseParagraph(_ element: Element) -> [ChapterParagraph] {
        let alignment = parseAlignment(element)
        
        var chapterItems: [ChapterParagraph] = []
        
        do {
            let outerHTML = try element.outerHtml()
            if element.children().count > 0 && outerHTML.contains("img") {
                for child in element.children() {
                    let html = try child.outerHtml()
                    if html.contains("img") {
                        let imageRaw = try child.select("img").first()
                        guard let imageLink = try imageRaw?.attr("src") else { continue }
                        let imageAltText = try imageRaw?.attr("alt")
                        chapterItems.append(ChapterParagraph(text: nil, image: imageLink, altText: imageAltText, alignment: alignment))
                    } else {
                        guard let text = child.attributedText() else { continue }
                        chapterItems.append(ChapterParagraph(text: text, image: nil, altText: nil, alignment: alignment))
                    }
                }
            } else {
                guard let text = element.attributedText() else { return chapterItems }
                chapterItems.append(ChapterParagraph(text: text, image: nil, altText: nil, alignment: alignment))
            }
        } catch {
            return chapterItems
        }
        
        return chapterItems
    }
    
    private static func parseAlignment(_ elements: Element) -> Alignment {
        var alignment: Alignment = .leading
        
        do {
            let html = try elements.outerHtml()
            if html.starts(with: "<p align=center") {
                alignment = .center
            } else if html.starts(with: "<p align=right") {
                alignment = .trailing
            }
            
            return alignment
        } catch {
            return alignment
        }
    }
}
