//
//  ChapterList.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation

public struct ChapterList: Hashable {
    public let chapters: [LinkInfo]
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(chapters)
    }
}
