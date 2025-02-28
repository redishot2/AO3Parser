//
//  News.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
import SwiftUI

public struct News {
    let articles: [Article]
    let tags: [Link]
    let translations: [Link]
    let pagesCount: Int
}

public enum HTMLTextSize {
    case h1
    case h2
    case h3
    case h4
    case h5
    case h6
    
    var font: Font {
        switch self {
            case .h1:
                return .title
            case .h2:
                return .title2
            case .h3:
                return .body
            case .h4:
                return .caption
            case .h5:
                return .caption2
            case .h6:
                return .footnote
        }
    }
}

public class Article: Equatable, Hashable {
    enum Content: Equatable, Hashable {
        case image(url: String)
        case header(text: String, size: HTMLTextSize)
        case list(items: [AttributedString])
        case paragraph(text: AttributedString)
        case divider
        
        public func hash(into hasher: inout Hasher) {
            switch self {
                case .paragraph(let text):
                    hasher.combine(text)
                case .image(url: let url):
                    hasher.combine(url)
                case .header(let text, let size):
                    hasher.combine(text)
                    hasher.combine(size.hashValue)
                case .list(items: let items):
                    hasher.combine(items)
                case .divider:
                    hasher.combine("")
            }
        }
    }
    
    struct Comment: Equatable, Hashable {
        let username: Link
        let profilePicture: URL?
        let isVerified: Bool
        let commentText: String
        let timestamp: String
        let editedTimestamp: String?
        let replyingTo: String?
        var childComments: [Comment]
    }
    
    let title: String
    let timeStamp: Date
    let tags: [Link]
    var comments: [Comment] = []
    let commentURL: URL?
    let commentsCount: Int
    let text: [Content]
    
    var flavorText: AttributedString? {
        for paragraph in text {
            if case let .paragraph(flavorText) = paragraph {
                return flavorText
            }
        }
        
        return nil
    }
    
    var titleImage: URL? {
        for paragraph in text {
            if case let .image(url) = paragraph {
                return URL(string: url)
            }
        }
        
        return nil
    }
    
    var textWithoutCoverImage: [Content] {
        guard let titleImage = titleImage else {
            return text
        }
        
        var shortenedText = text
        let imageContent = Content.image(url: titleImage.absoluteString)
        
        shortenedText.removeAll(where: {
            $0 == imageContent
        })
        
        return shortenedText
    }
    
    var publishDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        let time = "\(dateFormatter.string(from: timeStamp)), \(timeFormatter.string(from: timeStamp))"
        return time
    }
    
    init(title: String, timeStamp: Date, tags: [Link], comments: [Comment] = [], commentURL: URL?, commentsCount: Int, text: [Content]) {
        self.title = title
        self.timeStamp = timeStamp
        self.tags = tags
        self.comments = comments
        self.commentURL = commentURL
        self.commentsCount = commentsCount
        self.text = text
    }
    
    public static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.text == rhs.text
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(timeStamp)
        hasher.combine(tags)
        hasher.combine(text)
    }
}
