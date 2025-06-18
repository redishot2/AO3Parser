//
//  CategoryInfo.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation

public struct CategoryInfo {
    public enum SortType: String {
        case alphabetical = "Alphabetical"
        case mostPopular = "Most Popular"
        case leastPopular = "Least Popular"
        
        public func all() -> [SortType] {
            return [.alphabetical, .mostPopular, .leastPopular]
        }
    }
    
    private let fandoms: [FandomGroup]
    
    init(fandoms: [FandomGroup]) {
        self.fandoms = fandoms
    }
    
    public func sort(by sortType: SortType) -> [FandomGroup] {
        switch sortType {
            case .alphabetical:
                return sortAlphabetical()
            case .mostPopular:
                return sortMostPopular()
            case .leastPopular:
                return sortLeastPopular()
        }
    }
    
    private func sortAlphabetical() -> [FandomGroup] {
        return fandoms
    }
    
    private func sortMostPopular() -> [FandomGroup] {
        let flatFandoms: [FandomItem] = fandoms.flatMap({ $0.fandoms })
        let sorted = flatFandoms.sorted(by: { $0.worksCount > $1.worksCount })
        
        return [FandomGroup(name: "Most Popular", fandoms: sorted)]
    }
    
    private func sortLeastPopular() -> [FandomGroup] {
        let flatFandoms: [FandomItem] = fandoms.flatMap({ $0.fandoms })
        let sorted = flatFandoms.sorted(by: { $0.worksCount < $1.worksCount })
        
        return [FandomGroup(name: "Least Popular", fandoms: sorted)]
    }
}

public struct FandomGroup: Identifiable, Hashable {
    public static func == (lhs: FandomGroup, rhs: FandomGroup) -> Bool {
        return lhs.name == rhs.name && lhs.fandoms == rhs.fandoms
    }
    
    public var id = UUID()
    
    public let name: String
    public let fandoms: [FandomItem]
    
    public init(name: String, fandoms: [FandomItem]) {
        self.name = name
        self.fandoms = fandoms
    }
}

public struct FandomItem: Hashable, Identifiable {
    public var id = UUID()
    
    public let name: String
    public let worksCount: Int
    
    public init(name: String, worksCount: Int) {
        self.name = name
        self.worksCount = worksCount
    }
}
