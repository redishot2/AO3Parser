//
//  StoryInfo.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
import SwiftUI

public struct Link: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let url: String
    public let name: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(name)
    }
}

public protocol TagsProtocol {
    var icon: String? { get }
    var fullText: LocalizedStringKey { get }
    var shortened: LocalizedStringKey { get }
    init?(filter: FeedFilterInfo.FilterInfo)
}

public struct StoryInfo {
    public class Filter: TagsProtocol {
        public let title: String
        public let type: FilterType
        
        public enum FilterType {
            case fandoms
            case characters
            case relationships
            case additionalTags
        }
        
        public var icon: String? {
            return nil
        }
        
        public var fullText: LocalizedStringKey {
            return LocalizedStringKey(title)
        }
        
        public var shortened: LocalizedStringKey {
            switch type {
                case .fandoms:
                    return LocalizedStringKey("👑")
                case .characters:
                    return LocalizedStringKey("🧑")
                case .relationships:
                    return LocalizedStringKey("💞")
                case .additionalTags:
                    return LocalizedStringKey("➕")
            }
        }
        
        public init(title: String, type: FilterType) {
            self.title = title
            self.type = type
        }
        
        public required convenience init?(filter: FeedFilterInfo.FilterInfo) {
            self.init(title: filter.name, type: .fandoms)
        }
    }
    
    public enum Rating: String, Codable, TagsProtocol {
        case explicit = "Explicit"
        case mature = "Mature"
        case teens = "Teen And Up Audiences"
        case generalAudiences = "General Audiences"
        case notRated = "Not Rated"
        
        public init?(filter: FeedFilterInfo.FilterInfo) {
            guard
                let name = filter.name.components(separatedBy: " (").first,
                let rating = Rating(rawValue: name)
            else { return nil }
            
            self = rating
        }
        
        public static var all: [Rating] {
            return [
                StoryInfo.Rating.generalAudiences,
                StoryInfo.Rating.teens,
                StoryInfo.Rating.mature,
                StoryInfo.Rating.explicit,
                StoryInfo.Rating.notRated
            ]
        }
        
        public var link: URL? {
            return Networking.generateURL(for: .relatedWorks(tag: rawValue))
        }
        
        public var icon: String? {
            return nil
        }
        
        public var fullText: LocalizedStringKey {
            switch self {
                case .explicit:
                    return "rating.explicit"
                case .mature:
                    return "rating.mature"
                case .teens:
                    return "rating.teens"
                case .generalAudiences:
                    return "rating.generalAudiences"
                case .notRated:
                    return "rating.notRated"
            }
        }
        
        public var shortened: LocalizedStringKey {
            switch self {
                case .explicit:
                    return "rating.explicit.short"
                case .mature:
                    return "rating.mature.short"
                case .teens:
                    return "rating.teens.short"
                case .generalAudiences:
                    return "rating.generalAudiences.short"
                case .notRated:
                    return "rating.notRated.short"
            }
        }
    }
    
    public enum Category: String, Codable, TagsProtocol {
        case fm = "F/M"
        case ff = "F/F"
        case mm = "M/M"
        case gen = "Gen"
        case multi = "Multi"
        case other = "Other"
        
        public init?(filter: FeedFilterInfo.FilterInfo) {
            guard
                let name = filter.name.components(separatedBy: " (").first,
                let category = Category(rawValue: name)
            else { return nil }
            
            self = category
        }
        
        public static var all: [Category] {
            return [
                StoryInfo.Category.fm,
                StoryInfo.Category.ff,
                StoryInfo.Category.mm,
                StoryInfo.Category.multi,
                StoryInfo.Category.gen,
                StoryInfo.Category.other
            ]
        }
        
        public var icon: String? {
            return nil
        }
        
        public var fullText: LocalizedStringKey {
            switch self {
                case .fm:
                    return "category.fm"
                case .ff:
                    return "category.ff"
                case .mm:
                    return "category.mm"
                case .gen:
                    return "category.gen"
                case .multi:
                    return "category.multi"
                case .other:
                    return "category.other"
            }
        }
        
        public var shortened: LocalizedStringKey {
            switch self {
                case .fm:
                    return "⚤"
                case .ff:
                    return "⚢"
                case .mm:
                    return "⚣"
                case .gen:
                    return "☉"
                case .multi:
                    return "❖"
                case .other:
                    return "✧"
            }
        }
        
        public init?(rawValue: String) {
            switch rawValue {
                case "F/M":
                    self = .fm
                case "F/F":
                    self = .ff
                case "M/M":
                    self = .mm
                case "Gen":
                    self = .gen
                case "Multi":
                    self = .multi
                case "Other": fallthrough
                default:
                    self = .other
            }
        }
    }
    
    public enum Warning: String, Codable, TagsProtocol {
        case violence = "Graphic Depictions Of Violence"
        case death = "Major Character Death"
        case rape = "Rape/Non-Con"
        case underage = "Underage"
        case unrated = "Creator Chose Not To Use Archive Warnings"
        case none = "No Archive Warnings Apply"
        
        public init?(filter: FeedFilterInfo.FilterInfo) {
            guard
                let name = filter.name.components(separatedBy: " (").first,
                let warning = Warning(rawValue: name)
            else { return nil }
            
            self = warning
        }
        
        public static var all: [Warning] {
            return [
                StoryInfo.Warning.death,
                StoryInfo.Warning.rape,
                StoryInfo.Warning.underage,
                StoryInfo.Warning.violence,
                StoryInfo.Warning.none,
                StoryInfo.Warning.unrated
            ]
        }
        
        public var link: URL? {
            return Networking.generateURL(for: .relatedWorks(tag: rawValue))
        }
        
        public var icon: String? {
            return nil
        }
        
        public var fullText: LocalizedStringKey {
            switch self {
                case .violence:
                    return "warning.violence"
                case .death:
                    return "warning.death"
                case .rape:
                    return "warning.rape"
                case .underage:
                    return "warning.underage"
                case .unrated:
                    return "warning.unrated"
                case .none:
                    return "warning.none"
            }
        }
        
        public var shortened: LocalizedStringKey {
            switch self {
                case .violence:
                    return "🔪"
                case .death:
                    return "☠️"
                case .rape:
                    return "❌"
                case .underage:
                    return "🧒"
                case .unrated:
                    return "❓"
                case .none:
                    return "❔"
            }
        }
    }
    
    public enum CompletionStatus: String, TagsProtocol {
        case inProgress = "This is a work in progress or is incomplete/unfulfilled."
        case completed = "This work is completed!/This prompt is filled!"
        
        public static var all: [CompletionStatus] {
            return [
                CompletionStatus.inProgress,
                CompletionStatus.completed
            ]
        }
        
        public var icon: String? {
            return nil
        }
        
        public var fullText: LocalizedStringKey {
            switch self {
                case .inProgress:
                    return "completion.inProgress"
                case .completed:
                    return "completion.completed"
            }
        }
        
        public var shortened: LocalizedStringKey {
            switch self {
                case .inProgress:
                    return "✏️"
                case .completed:
                    return "✔️"
            }
        }
        
        public init(_ raw: Bool?) {
            self = raw ?? false ? CompletionStatus.completed : CompletionStatus.inProgress
        }
        
        public init?(filter: FeedFilterInfo.FilterInfo) {
            self.init(false)
        }
    }
    
    public struct Stats: Codable {
        public let published: Date
        public let completed: Date?
        public let words: Int
        public let chapters: String
        public let comments: Int
        public let kudos: Int
        public let bookmarks: Int
        public let hits: Int
    }
    
    public let rating: Rating
    public let warnings: [Warning]
    public let categories: [Category]
    public let fandoms: [Link]
    public let relationships: [Link]
    public let characters: [Link]
    public let tags: [Link]
    public let language: String
    public let collections: [Link]
    public let stats: Stats
}

