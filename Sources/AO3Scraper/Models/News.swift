//
//  News.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
import SwiftUI

public struct News {
    public let articles: [Article]
    public let tags: [LinkInfo]
    public let translations: [LinkInfo]
    public let pagesCount: Int
}

public enum HTMLTextSize {
    case h1
    case h2
    case h3
    case h4
    case h5
    case h6
    
    public var font: Font {
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
    public enum Content: Equatable, Hashable {
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
    
    public struct Comment: Equatable, Hashable {
        public let username: LinkInfo
        public let profilePicture: URL?
        public let isVerified: Bool
        public let commentText: String
        public let timestamp: String
        public let editedTimestamp: String?
        public let replyingTo: String?
        public var childComments: [Comment]
    }
    
    public let title: String
    public let timeStamp: Date
    public let tags: [LinkInfo]
    public var comments: [Comment] = []
    public let commentURL: URL?
    public let commentsCount: Int
    public let text: [Content]
    
    public var flavorText: AttributedString? {
        for paragraph in text {
            if case let .paragraph(flavorText) = paragraph {
                return flavorText
            }
        }
        
        return nil
    }
    
    public var titleImage: URL? {
        for paragraph in text {
            if case let .image(url) = paragraph {
                return URL(string: url)
            }
        }
        
        return nil
    }
    
    public var textWithoutCoverImage: [Content] {
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
    
    public var publishDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        let time = "\(dateFormatter.string(from: timeStamp)), \(timeFormatter.string(from: timeStamp))"
        return time
    }
    
    public init(title: String, timeStamp: Date, tags: [LinkInfo], comments: [Comment] = [], commentURL: URL?, commentsCount: Int, text: [Content]) {
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
