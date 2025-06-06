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
    
    public let fandoms: [FandomGroup]
    
    public func sortedFandoms(by sortType: SortType) -> [FandomGroup] {
        return sort(by: sortType)
    }
    
    private func sort(by sortType: SortType) -> [FandomGroup] {
        switch sortType {
            case .alphabetical:
                return fandoms
            case .mostPopular:
                let sort = sortMostPopular()
                return sort
            case .leastPopular:
                let sort = sortLeastPopular()
                return sort
        }
    }
    
    private func sortMostPopular() -> [FandomGroup] {
        let flatFandoms: [FandomItem] = fandoms.flatMap({ $0.fandoms })
        let sorted = flatFandoms.sorted(by: { $0.worksCount > $1.worksCount })
        
        return [FandomGroup(name: SortType.mostPopular.rawValue, fandoms: sorted)]
    }
    
    private func sortLeastPopular() -> [FandomGroup] {
        let flatFandoms: [FandomItem] = fandoms.flatMap({ $0.fandoms })
        let sorted = flatFandoms.sorted(by: { $0.worksCount < $1.worksCount })
        
        return [FandomGroup(name: SortType.leastPopular.rawValue, fandoms: sorted)]
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

public struct FandomItem: Hashable {
    public let name: String
    public let worksCount: Int
}
