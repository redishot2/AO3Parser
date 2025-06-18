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
    
    public func sort(by sortType: SortType) -> [FandomItem] {
        switch sortType {
            case .alphabetical:
                return sortAlphabetical()
            case .mostPopular:
                let sort = sortMostPopular()
                return sort
            case .leastPopular:
                let sort = sortLeastPopular()
                return sort
        }
    }
    
    private func sortAlphabetical() -> [FandomItem] {
        let flatFandoms: [FandomItem] = fandoms.flatMap({ $0.fandoms })
        
        return flatFandoms
    }
    
    private func sortMostPopular() -> [FandomItem] {
        let flatFandoms: [FandomItem] = fandoms.flatMap({ $0.fandoms })
        let sorted = flatFandoms.sorted(by: { $0.worksCount > $1.worksCount })
        
        return sorted
    }
    
    private func sortLeastPopular() -> [FandomItem] {
        let flatFandoms: [FandomItem] = fandoms.flatMap({ $0.fandoms })
        let sorted = flatFandoms.sorted(by: { $0.worksCount < $1.worksCount })
        
        return sorted
    }
}

public struct FandomGroup: Identifiable, Hashable {
    public static func == (lhs: FandomGroup, rhs: FandomGroup) -> Bool {
        return lhs.name == rhs.name && lhs.fandoms == rhs.fandoms
    }
    
    public var id = UUID()
    
    public let name: String
    public let fandoms: [FandomItem]
}

public struct FandomItem: Hashable, Identifiable {
    public var id = UUID()
    
    public let name: String
    public let worksCount: Int
}
