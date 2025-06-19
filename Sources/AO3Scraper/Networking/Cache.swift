//
//  File.swift
//  AO3Scraper
//
//  Created by Natasha Martinez on 6/19/25.
//

import Foundation

internal class Cache {
    private var cache: [String: Any] = [:]
    
    private(set) nonisolated(unsafe) static var shared = Cache()
    
    internal func getCachedData(for url: URL) -> Any? {
        return cache[url.absoluteString]
    }
    
    internal func cacheData(_ data: Any, for url: URL) {
        cache[url.absoluteString] = data
    }
}
