//
//  Chapter.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
import SwiftUI

public struct ChapterParagraph: Identifiable {
    public var id = UUID()
    
    let text: AttributedString?
    let image: String?
    let altText: String?
    var alignment: Alignment
    
    var imageURL: URL? {
        guard let imageString = image else { return nil }
        return URL(string: imageString)
    }
}

public struct Chapter {
    let title: Link
    let paragraphs: [ChapterParagraph]
    let preNotes: [ChapterParagraph]
    let postNotes: [ChapterParagraph]
    
    var firstImage: URL? {
        guard let paragraph = paragraphs.first(where: { $0.image != nil }), let image = paragraph.image else { return nil }
        return URL(string: image)
    }
}
