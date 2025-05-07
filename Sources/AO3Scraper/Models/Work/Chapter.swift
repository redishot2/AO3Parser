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
    
    public let text: AttributedString?
    public let image: String?
    public let altText: String?
    public var alignment: Alignment
    
    public var imageURL: URL? {
        guard let imageString = image else { return nil }
        return URL(string: imageString)
    }
}

public struct Chapter {
    public let paragraphs: [ChapterParagraph]
    public let preNotes: [ChapterParagraph]
    public let postNotes: [ChapterParagraph]
    
    public var firstImage: URL? {
        guard let paragraph = paragraphs.first(where: { $0.image != nil }), let image = paragraph.image else { return nil }
        return URL(string: image)
    }
}
