//
//  CategoryInfo.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation

public struct CategoryInfo {
    enum SortType: String {
        case alphabetical = "Alphabetical"
        case mostPopular = "Most Popular"
        case leastPopular = "Least Popular"
        
        func all() -> [SortType] {
            return [.alphabetical, .mostPopular, .leastPopular]
        }
    }
    
    let fandoms: [FandomGroup]
    
    func sortedFandoms(by sortType: SortType) -> [FandomGroup] {
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

struct FandomGroup: Identifiable, Hashable {
    static func == (lhs: FandomGroup, rhs: FandomGroup) -> Bool {
        return lhs.name == rhs.name && lhs.fandoms == rhs.fandoms
    }
    
    var id = UUID()
    
    let name: String
    let fandoms: [FandomItem]
}

struct FandomItem: Hashable {
    let name: String
    let worksCount: Int
}
