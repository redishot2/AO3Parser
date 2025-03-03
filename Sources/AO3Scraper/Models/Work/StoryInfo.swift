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
    var fullText: String { get }
    var shortened: String { get }
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
        
        public var fullText: String {
            return title
        }
        
        public var shortened: String {
            switch type {
                case .fandoms:
                    return "👑"
                case .characters:
                    return "🧑"
                case .relationships:
                    return "💞"
                case .additionalTags:
                    return "➕"
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
        
        public var fullText: String {
            self.rawValue
        }
        
        public var shortened: String {
            switch self {
                case .explicit:
                    return "X"
                case .mature:
                    return "M"
                case .teens:
                    return "T"
                case .generalAudiences:
                    return "G"
                case .notRated:
                    return "U"
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
        
        public var fullText: String {
            switch self {
                case .fm:
                    return "Straight Pairing"
                case .ff:
                    return "Female Pairing"
                case .mm:
                    return "Male Pairing"
                case .gen:
                    return "No Pairings"
                case .multi:
                    return "Multiple Partners"
                case .other:
                    return "Other Pairing"
            }
        }
        
        public var shortened: String {
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
        
        public var fullText: String {
            return self.rawValue
        }
        
        public var shortened: String {
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
        
        public var fullText: String {
            switch self {
                case .inProgress:
                    return "In Progress"
                case .completed:
                    return "Completed"
            }
        }
        
        public var shortened: String {
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

